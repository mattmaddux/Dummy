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
    
    public static var pexelsAPIKey: String? = nil
    
    @Published public var items: [DummyItem] = [DummyItem]()
    
    private let api = API()
    private let perPage: UInt
    private let minPara: UInt
    private let maxPara: UInt
    private let lengths: [SnippetParagraphLength]
    private let searchQueries: [String]
    private let seed: String
    private let shouldLoadElements: [DummyElement]
    private var nextPage: UInt = 1
    
    
    private var userQueue = [DummyUser]()
    private var snippetQueue = [String]()
    private var photoQueue = [DummyPhoto]()
    private var videoQueue = [DummyVideo]()
    
    
    public init(itemCount perPage: UInt = 15,
                minSnippetParagraphs minPara: UInt = 1,
                maxTextParagraphs maxPara: UInt = 2,
                snippetParagraphLengths lengths: [SnippetParagraphLength] = SnippetParagraphLength.allCases,
                searchQueries: [String] = [String](),
                loadElements shouldLoadElements: [DummyElement] = DummyElement.allCases
                ) {
        self.perPage = perPage
        self.minPara = min(minPara, maxPara)
        self.maxPara = max(minPara, maxPara)
        self.lengths = lengths
        self.searchQueries = searchQueries
        self.seed = CharacterSet.lowercaseLetters.randomString(length: 12)
        self.shouldLoadElements = shouldLoadElements
        
        
        let previewMode: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        guard !previewMode else {
            items = [DummyItem](repeating: previewItem, count: Int(perPage))
            return
        }
        loadNextPage()
    }
    
    public func loadNextPage() {
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
        
    }
     
    private func checkQueue() {
        guard userQueue.count == perPage,
              snippetQueue.count == perPage,
              photoQueue.count == perPage,
              videoQueue.count == perPage else { return }
        var newItems = [DummyItem]()
        for _ in 0..<perPage {
            newItems.append(DummyItem(user: userQueue.removeFirst(),
                                      snippet: snippetQueue.removeFirst(),
                                      photo: photoQueue.removeFirst(),
                                      video: videoQueue.removeFirst()))
        }
        userQueue.removeAll()
        snippetQueue.removeAll()
        photoQueue.removeAll()
        videoQueue.removeAll()
        nextPage = nextPage + 1
        DispatchQueue.main.async {
            self.items.append(contentsOf: newItems)
        }
    }
    
    private func getUsers() {
        let baseURL = URL(string: "https://randomuser.me/api/")!
        let queries = ["seed": self.seed, "results": String(perPage), "page": String(nextPage)]
        do {
            try api.get(atURL: baseURL, withQueries: queries, responseType: DummyUserResponse.self) { response, rawResponse in
                guard let users = response?.results else { return }
                guard users.count == self.perPage else { return }
                self.userQueue = users
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }
    
    private func getSnippets() {
        
        var allSnippets = [String]()
        
        for _ in 0..<perPage {
            let num = UInt.random(in: minPara...maxPara)
            let length = lengths.randomElement() ?? .medium
            getSnippet(paragraphCount: num, paragraphLength: length, options: [SnippetOptions]()) { text in
                allSnippets.append(text)
                if allSnippets.count == self.perPage {
                    guard allSnippets.count == self.perPage else { return }
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
        guard let pexelsAPIKey = Dummy.pexelsAPIKey else { return }
        var baseURL = URL(string: "https://api.pexels.com/v1/")!
        let headers = ["Authorization":pexelsAPIKey]
        var queries = ["per_page": String(perPage), "page": String(nextPage)]
        if searchQueries.count == 0 {
            baseURL.appendPathComponent("curated")
        } else {
            baseURL.appendPathComponent("search")
            let queryString = searchQueries.joined(separator: ", ")
            queries["query"] = queryString
        }
        do {
            try api.get(atURL: baseURL, withQueries: queries, andHeaders: headers, responseType: DummyPhotoResponse.self) { response, rawResponse in
                guard let photos = response?.photos else { return }
                guard photos.count == self.perPage else { return }
                self.photoQueue = photos
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }
    
    
    private func getVideos() {
        guard let pexelsAPIKey = Dummy.pexelsAPIKey else { return }
        var baseURL = URL(string: "https://api.pexels.com/videos/")!
        let headers = ["Authorization":pexelsAPIKey]
        var queries = ["per_page": String(perPage), "page": String(nextPage)]
        if searchQueries.count == 0 {
            baseURL.appendPathComponent("popular")
        } else {
            baseURL.appendPathComponent("search")
            let queryString = searchQueries.joined(separator: ", ")
            queries["query"] = queryString
        }
        do {
            try api.get(atURL: baseURL, withQueries: queries, andHeaders: headers, responseType: DummyVideoResponse.self) { response, rawResponse in
                guard let videos = response?.videos else { return }
                guard videos.count == self.perPage else { return }
                self.videoQueue = videos
                self.checkQueue()
            }
        } catch {
            print(error)
        }
    }

}



