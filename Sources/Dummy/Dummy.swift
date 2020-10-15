//
//  Dummy.swift
//
//  Created by Matt Maddux on 10/13/20.
//
// Using API's from:
//  - Images: https://pexels.com
//  - Users: https://randomuser.me
//  - Text: https://loripsum.net
//

import Foundation
import SwiftUI

class Dummy: ObservableObject {
    
    private let api = API()
    
    static func standard() -> Dummy {
        let dummy = Dummy()
        dummy.loadUsers()
        dummy.loadTexts()
//        dummy.loadImages()
        return dummy
    }
    
    // ======================================================= //
    // MARK: - Users
    // ======================================================= //
    
    @Published var users: [DummyUser] = [DummyUser]()
    
    func loadUsers(count: Int = 10, including: [DummyUser.Parameter]? = nil, excluding: [DummyUser.Parameter]? = nil) {
        self.getUsers(count: count, including: including, excluding: excluding) { users in
            DispatchQueue.main.async {
                self.users.append(contentsOf: users)
            }
        }
    }
    
    func getUsers(count: Int = 10, including: [DummyUser.Parameter]? = nil, excluding: [DummyUser.Parameter]? = nil, completion: @escaping ([DummyUser]) -> Void ) {
        let baseURL = URL(string: "https://randomuser.me/api/")!
        var queries = ["results": String(count)]
        if let including = including {
            queries["inc"] = including.reduce("") { $0 + "\($1.rawValue)," }
        } else if let excluding = excluding {
            queries["exc"] = excluding.reduce("") { $0 + "\($1.rawValue)," }
        }
        do {
            try api.get(atURL: baseURL, withQueries: queries, responseType: DummyUserResponse.self) { response, rawResponse in
                guard let users = response?.results else { return }
                completion(users)
            }
        } catch {
            print(error)
        }
    }
    
    // ======================================================= //
    // MARK: - Texts
    // ======================================================= //
    
    @Published var texts: [String] = [String]()
    
    
    func loadTexts(count textCount: Int = 10, minParagraphs: UInt = 1, maxParagraphs: UInt = 2, paragraphLengths: [TextParagraphLength] = TextParagraphLength.allCases, options: [TextOptions] = [TextOptions]()) {
        getTexts(count: textCount, minParagraphs: minParagraphs, maxParagraphs: maxParagraphs, paragraphLengths: paragraphLengths, options: options) { texts in
            DispatchQueue.main.async {
                self.texts.append(contentsOf: texts)
            }
        }
    }
    
    func getTexts(count textCount: Int = 10, minParagraphs: UInt = 1, maxParagraphs: UInt = 2, paragraphLengths: [TextParagraphLength] = TextParagraphLength.allCases, options: [TextOptions] = [TextOptions](), completion: @escaping ([String]) -> Void ) {
        
        var allTexts = [String]()
        let minPara = min(minParagraphs, maxParagraphs)
        let maxPara = max(minParagraphs, maxParagraphs)
        
        for _ in 0..<textCount {
            let num = UInt.random(in: minPara...maxPara)
            let length = paragraphLengths.randomElement() ?? .medium
            getText(paragraphCount: num, paragraphLength: length, options: options) { text in
                allTexts.append(text)
                if allTexts.count == textCount {
                    completion(allTexts)
                }
            }
        }
    }
    
    func getText(paragraphCount: UInt, paragraphLength: TextParagraphLength, options: [TextOptions], completion: @escaping (String) -> Void ) {
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

}
