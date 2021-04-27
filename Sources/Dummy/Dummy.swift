//
//  Dummy.swift
//
//  Created by Matt Maddux on 10/13/20.
//
// Using API's from:
//  - Images: https://pexels.com
//  - Users: https://randomuser.me
//  - Snippets: https://loripsum.net
//

import Foundation
import SwiftUI


public class Dummy: ObservableObject {
    
    // ======================================================= //
    // MARK: - Static Properties
    // ======================================================= //
    
    public static var pexelsAPIKey: String? = nil
    
    // ======================================================= //
    // MARK: - Published Properties
    // ======================================================= //
    
    @Published public var items: [DummyItem] = [DummyItem]()
    @Published public var perPage: UInt
    @Published public var minPara: UInt
    @Published public var maxPara: UInt
    @Published public var lengths: Set<SnippetParagraphLength>
    @Published public var searchQuery: String
    @Published public var userNationalities: Set<DummyUser.Nationality>
    @Published public private(set) var loading: Bool = false
    
    @Published public private(set) var savedUsers = [DummyUser]()
    @Published public private(set) var savedSnippets = [String]()
    @Published public private(set) var savedPhotos = [DummyPhoto]()
    @Published public private(set) var savedVideos = [DummyVideo]()
    
    // ======================================================= //
    // MARK: - Private Properties
    // ======================================================= //
    
    private let api = API()
    private var seed: String
    private let shouldLoadElements: [DummyElement]
    private var nextPage: UInt = 1
    private var userQueue = [DummyUser]()
    private var snippetQueue = [String]()
    private var photoQueue = [DummyPhoto]()
    private var videoQueue = [DummyVideo]()
    
    
    // ======================================================= //
    // MARK: - Initializer
    // ======================================================= //
    
    public init(itemCount perPage: UInt = 15,
                userNationalities: Set<DummyUser.Nationality> = Set(DummyUser.Nationality.allCases),
                minSnippetParagraphs minPara: UInt = 1,
                maxTextParagraphs maxPara: UInt = 2,
                snippetParagraphLengths lengths: Set<SnippetParagraphLength> = Set(SnippetParagraphLength.allCases),
                searchQuery: String = "",
                loadElements shouldLoadElements: [DummyElement] = DummyElement.allCases,
                showSaved: Bool = true) {
        self.perPage = perPage
        self.userNationalities = userNationalities
        let minPara = minPara > 0 && minPara < 11 ? minPara : 1
        let maxPara = maxPara > 0 && maxPara < 11 ? maxPara : 1
        self.minPara = min(minPara, maxPara)
        self.maxPara = max(minPara, maxPara)
        self.lengths = lengths
        self.searchQuery = searchQuery
        self.seed = CharacterSet.lowercaseLetters.randomString(length: 12)
        self.shouldLoadElements = shouldLoadElements
        
        
        let previewMode: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        guard !previewMode else {
            items = [DummyItem](repeating: previewItem, count: Int(perPage))
            return
        }
        
        readSavedFromUserDefaults()
        if showSaved {
            displaySavedItems()
        } else {
            loadNextPage()
        }
    }
    
    // ======================================================= //
    // MARK: - Public Methods
    // ======================================================= //
    
    public func reload() {
        self.items = [DummyItem]()
        self.seed = CharacterSet.lowercaseLetters.randomString(length: 12)
        self.nextPage = 1
        self.loadNextPage()
    }
    
    public func loadNextPage() {
        self.loading = true
        guard Dummy.pexelsAPIKey != nil else { return }
        
        if shouldLoadElements.contains(.user) {
            getUsers()
        } else {
            userQueue = [DummyUser].init(repeating: previewUser, count: Int(perPage))
        }
        
        if shouldLoadElements.contains(.snippet) {
            getSnippets()
        } else {
            snippetQueue = [String].init(repeating: previewSnippet, count: Int(perPage))
        }
        
        if shouldLoadElements.contains(.photo) && Dummy.pexelsAPIKey != nil {
            getPhotos()
        } else {
            photoQueue = [DummyPhoto].init(repeating: previewPhoto, count: Int(perPage))
        }
        
        if shouldLoadElements.contains(.video) && Dummy.pexelsAPIKey != nil {
            getVideos()
        } else {
            videoQueue = [DummyVideo].init(repeating: previewVideo, count: Int(perPage))
        }
        checkQueue()
    }
    
    public func save(dummyData: DummyData) {
        
        switch dummyData {
        
            case is DummyUser:
                let user = dummyData as! DummyUser
                self.savedUsers.append(user)
                if let i = items.firstIndex(where: { $0.user.id == user.id }) {
                    self.items.remove(at: i)
                }
                if let data = user.profilePictureData {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user-\(user.id)")
                    try? data.write(to: url)
                }
                
            case is DummySnippet:
                let snippet = dummyData as! DummySnippet
                self.savedSnippets.append(snippet)
                if let i = items.firstIndex(where: { $0.snippet == snippet }) {
                    self.items.remove(at: i)
                }
                
            case is DummyPhoto:
                let photo = dummyData as! DummyPhoto
                self.savedPhotos.append(photo)
                if let i = items.firstIndex(where: { $0.photo.id == photo.id }) {
                    self.items.remove(at: i)
                }
                if let data = photo.imageData {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo-\(photo.id)")
                    try? data.write(to: url)
                }
                
                
            case is DummyVideo:
                let video = dummyData as! DummyVideo
                self.savedVideos.append(video)
                if let i = items.firstIndex(where: { $0.video.id == video.id }) {
                    self.items.remove(at: i)
                }
                if let data = video.screenshotData {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video-\(video.id)")
                    try? data.write(to: url)
                }
                
            default: break
        }
        
        writeSavedToUserDefaults()
        
    }
    
    public func remove(dummyData: DummyData) {
        switch dummyData {
            case is DummyUser:
                let user = dummyData as! DummyUser
                if let i = savedUsers.firstIndex(where: { $0.id == user.id }) {
                    self.savedUsers.remove(at: i)
                }
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user-\(user.id)")
                try? FileManager.default.removeItem(at: url)
                
            case is DummySnippet:
                let snippet = dummyData as! DummySnippet
                if let i = savedSnippets.firstIndex(where: { $0 == snippet }) {
                    self.savedSnippets.remove(at: i)
                }

            case is DummyPhoto:
                let photo = dummyData as! DummyPhoto
                if let i = savedPhotos.firstIndex(where: { $0.id == photo.id }) {
                    self.savedPhotos.remove(at: i)
                }
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo-\(photo.id)")
                try? FileManager.default.removeItem(at: url)

                
            case is DummyVideo:
                let video = dummyData as! DummyVideo
                if let i = savedVideos.firstIndex(where: { $0.id == video.id }) {
                    self.savedVideos.remove(at: i)
                }
                let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video-\(video.id)")
                try? FileManager.default.removeItem(at: url)

            default: break
        }
        writeSavedToUserDefaults()
        
    }
    
    public func remove(dummyType: DummyElement, atIndexSet indexSet: IndexSet) {
        for index in indexSet {
            switch dummyType {
                case .user:
                    let user = savedUsers[index]
                    savedUsers.remove(at: index)
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user-\(user.id)")
                    try? FileManager.default.removeItem(at: url)
                    
                case .snippet:
                    savedSnippets.remove(at: index)
                    
                case .photo:
                    let photo = savedPhotos[index]
                    savedPhotos.remove(at: index)
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo-\(photo.id)")
                    try? FileManager.default.removeItem(at: url)
                    
                case .video:
                    let video = savedVideos[index]
                    savedVideos.remove(at: index)
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video-\(video.id)")
                    try? FileManager.default.removeItem(at: url)
                    
            }
        }
        writeSavedToUserDefaults()
    }
    
    public func moveSaved(dummyType: DummyElement, fromIndex start: IndexSet, toIndex end: Int) {
        switch dummyType {
            case .user: savedUsers.move(fromOffsets: start, toOffset: end)
            case .snippet: savedSnippets.move(fromOffsets: start, toOffset: end)
            case .photo: savedPhotos.move(fromOffsets: start, toOffset: end)
            case .video: savedVideos.move(fromOffsets: start, toOffset: end)
        }
        writeSavedToUserDefaults()
    }
     
    // ======================================================= //
    // MARK: - Private Methods
    // ======================================================= //
    
    
    private func writeSavedToUserDefaults() {
        if shouldLoadElements.contains(.user) {
            let userArray = self.savedUsers.map { $0.dict }
            UserDefaults.standard.set(userArray, forKey: "users")
        }
        if shouldLoadElements.contains(.snippet) {
            UserDefaults.standard.set(savedSnippets, forKey: "snippets")
        }
        if shouldLoadElements.contains(.photo) {
            let photoArray = self.savedPhotos.map { $0.dict }
            UserDefaults.standard.set(photoArray, forKey:  "photos")
        }
        if shouldLoadElements.contains(.video) {
            let videoArray = self.savedVideos.map { $0.dict }
            UserDefaults.standard.set(videoArray, forKey: "videos")
        }

    }
    
    private func readSavedFromUserDefaults() {
        if shouldLoadElements.contains(.user) {
            if let userArray = UserDefaults.standard.array(forKey: "users") as? [[String:String]] {
                self.savedUsers = userArray.map { DummyUser(fromDict: $0)}
                for index in 0..<savedUsers.count {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user-\(savedUsers[index].id)")
                    if let data = try? Data(contentsOf: url) {
                        savedUsers[index].profilePictureData = data
                    }
                }
            }
        }
        if shouldLoadElements.contains(.snippet) {
            self.savedSnippets = UserDefaults.standard.array(forKey: "snippets") as? [String] ?? [String]()
        }
        if shouldLoadElements.contains(.photo) {
            if let photoArray = UserDefaults.standard.array(forKey: "photos") as? [[String:String]] {
                self.savedPhotos = photoArray.map { DummyPhoto(fromDict: $0)}
                for index in 0..<savedPhotos.count {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photo-\(savedPhotos[index].id)")
                    if let data = try? Data(contentsOf: url) {
                        savedPhotos[index].imageData = data
                    }
                }
            }
        }
        if shouldLoadElements.contains(.video) {
            if let videoArray = UserDefaults.standard.array(forKey: "videos") as? [[String:String]] {
                self.savedVideos = videoArray.map { DummyVideo(fromDict: $0)}
                for index in 0..<savedVideos.count {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("video-\(savedVideos[index].id)")
                    if let data = try? Data(contentsOf: url) {
                        savedVideos[index].screenshotData = data
                    }
                }
            }
        }
    }
    
    private func displaySavedItems() {
        let maxCount = max(savedUsers.count, savedSnippets.count, savedPhotos.count, savedVideos.count)
        var dateQueue = Date.recentDates(count: Int(maxCount))
        for i in 0..<maxCount {
            items.append(DummyItem(user: savedUsers.count > i ? savedUsers[i] : previewUser,
                                   snippet: savedSnippets.count > i ? savedSnippets[i] : previewSnippet,
                                   photo: savedPhotos.count > i ? savedPhotos[i] : previewPhoto,
                                   video: savedVideos.count > i ? savedVideos[i] : previewVideo,
                                   date: dateQueue.removeFirst()))
        }
    }
    
    private func checkQueue() {
        print("Checking Queue")
        guard userQueue.count == perPage,
              snippetQueue.count == perPage,
              photoQueue.count == perPage,
              videoQueue.count == perPage else {
            print("Not ready")
            return
            
        }
        var newItems = [DummyItem]()
        var dateQueue = Date.recentDates(count: Int(perPage))
        for _ in 0..<perPage {
            newItems.append(DummyItem(user: userQueue.removeFirst(),
                                      snippet: snippetQueue.removeFirst(),
                                      photo: photoQueue.removeFirst(),
                                      video: videoQueue.removeFirst(),
                                      date: dateQueue.removeFirst()))
        }
        userQueue.removeAll()
        snippetQueue.removeAll()
        photoQueue.removeAll()
        videoQueue.removeAll()
        nextPage = nextPage + 1
        DispatchQueue.main.async {
            print("Queue ready, adding to list")
            self.items.append(contentsOf: newItems)
            self.loading = false
        }
    }
    
    private func getUsers() {
        print("Getting Users")
        let baseURL = URL(string: "https://randomuser.me/api/")!
        let queries = ["seed": self.seed,
                       "results": String(perPage),
                       "page": String(nextPage),
                       "nat": userNationalities.map( { $0.rawValue }).joined(separator: ",")]
        do {
            try api.get(atURL: baseURL, withQueries: queries, responseType: DummyUserResponse.self) { response, rawResponse in
                guard let users = response?.results else { return }
                guard users.count == self.perPage else { return }
                print("Got Users - adding to queue")
                self.userQueue = users
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }
    
    private func getSnippets() {
        print("Getting snippets")
        var allSnippets = [String]()
        
        for _ in 0..<perPage {
            let num = UInt.random(in: minPara...maxPara)
            let length = lengths.randomElement() ?? .medium
            getSnippet(paragraphCount: num, paragraphLength: length, options: [SnippetOptions]()) { text in
                allSnippets.append(text)
                if allSnippets.count == self.perPage {
                    guard allSnippets.count == self.perPage else { return }
                    print("Got Snippets - adding to queue")
                    self.snippetQueue = allSnippets
                    self.checkQueue()
                }
            }
        }
    }
    
    private func getSnippet(paragraphCount: UInt, paragraphLength: SnippetParagraphLength, options: [SnippetOptions], completion: @escaping (String) -> Void ) {
        var url = URL(string: "https://loripsum.net/api/")!
        url.appendPathComponent(String(paragraphCount))
        url.appendPathComponent(paragraphLength.rawValue)
        
        var options = options
        if options.contains(.html) {
            options.removeAll() { $0 == .html }
        } else {
            url.appendPathComponent("plaintext")
        }
        
        for option in options {
            url.appendPathComponent(option.rawValue)
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let result = String(data: data, encoding: .utf8) else { return }
            completion(result)
        }
        
        task.resume()
    }

    private func getPhotos() {
        print("Getting Photos")
        guard let pexelsAPIKey = Dummy.pexelsAPIKey else { return }
        var baseURL = URL(string: "https://api.pexels.com/v1/")!
        let headers = ["Authorization":pexelsAPIKey]
        var queries = ["per_page": String(perPage), "page": String(nextPage)]
        if searchQuery == "" {
            baseURL.appendPathComponent("curated")
        } else {
            baseURL.appendPathComponent("search")
            queries["query"] = searchQuery
        }
        do {
            try api.get(atURL: baseURL, withQueries: queries, andHeaders: headers, responseType: DummyPhotoResponse.self) { response, rawResponse in
                guard let photos = response?.photos else { return }
                guard photos.count == self.perPage else { return }
                print("Got Photos - adding to queue")
                self.photoQueue = photos
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }
    
    
    private func getVideos() {
        print("Getting Videos")
        guard let pexelsAPIKey = Dummy.pexelsAPIKey else { return }
        var baseURL = URL(string: "https://api.pexels.com/videos/")!
        let headers = ["Authorization":pexelsAPIKey]
        var queries = ["per_page": String(perPage), "page": String(nextPage)]
        if searchQuery == "" {
            baseURL.appendPathComponent("curated")
        } else {
            baseURL.appendPathComponent("search")
            queries["query"] = searchQuery
        }
        do {
            try api.get(atURL: baseURL, withQueries: queries, andHeaders: headers, responseType: DummyVideoResponse.self) { response, rawResponse in
                guard let videos = response?.videos else { return }
                guard videos.count == self.perPage else { return }
                print("Got Videos - adding to queue")
                self.videoQueue = videos
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }

}



