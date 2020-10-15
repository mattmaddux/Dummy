//
//  DummyTypes.swift
//
//  Created by Matt Maddux on 10/13/20.
//

import Foundation
import UIKit
import SwiftUI

// ======================================================= //
// MARK: - Users
// ======================================================= //

struct DummyUser: Codable, Identifiable {
    
    // ======================================================= //
    // MARK: - Sub-Types
    // ======================================================= //
    
    enum Gender: String, Codable {
        case male, female
    }
    
    enum Nationality: String, Codable {
        case AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NO, NL, NZ, TR, US
    }
    
    struct Name: Codable {
        let title: String?
        let first: String?
        let last: String?
    }
    
    struct Street: Codable {
        let number: Int
        let name: String
    }
    
    struct Location: Codable {
        
        enum CodingKeys: CodingKey {
            case street, city, state, postcode, coordinates, timezone
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            street = try container.decode(Street.self, forKey: .street)
            city = try container.decode(String.self, forKey: .city)
            state = try container.decode(String.self, forKey: .state)
            coordinates = try container.decode(Coordinates.self, forKey: .coordinates)
            timezone = try container.decode(Timezone.self, forKey: .timezone)
            if let postcodeString = try? container.decode(String.self, forKey: .postcode) {
                postcode = postcodeString
            } else if let postcodeInt = try? container.decode(Int.self, forKey: .postcode) {
                postcode = String(postcodeInt)
            } else {
                postcode = ""
            }
        }
        
        let street: Street
        let city: String
        let state: String
        let postcode: String
        let coordinates: Coordinates
        let timezone: Timezone
    }
    
    struct Coordinates: Codable {
        let latitude: String
        let longitude: String
    }
    
    struct Timezone: Codable {
        let offset: String
        let description: String
    }
    
    struct Login: Codable {
        let uuid: String
        let username: String
        let password: String
        let salt: String
        let md5: String
        let sha1: String
        let sha256: String
    }
    
    struct Age: Codable {
        let date: Date
        let age: Int
    }
    
    struct Identification: Codable {
        let name: String?
        let value: String?
    }
    
    struct imageURLSet: Codable {
        
        enum CodingKeys: String, CodingKey {
            case largeURL = "large"
            case mediumURL = "medium"
            case thumbURL = "thumbnail"
        }
        
        let largeURL: URL
        let mediumURL: URL
        let thumbURL: URL
        
        var large: Image { return loadImage(at: largeURL) }
        var medium: Image { return loadImage(at: mediumURL) }
        var thumb: Image { return loadImage(at: thumbURL) }
        
        private func loadImage(at url: URL) -> Image {
            guard let data = try? Data(contentsOf: url),
                  let uiImage = UIImage(data: data) else {
                      return Image(systemName: "person.fill")
                  }
            return Image(uiImage: uiImage)
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case gender, name, location, email, login, dob, registered, phone, cell
        case nationality = "nat"
        case identification = "id"
        case profilePicture = "picture"
    }
    
    typealias Parameter = CodingKeys
    
    // ======================================================= //
    // MARK: - Properties
    // ======================================================= //
    
    let id: UUID = UUID()
    let gender: Gender?
    let name: Name?
    let location: Location?
    let email: String?
    let login: Login?
    let dob: Age?
    let registered: Age?
    let phone: String?
    let cell: String?
    let identification: Identification?
    let nationality: Nationality?
    let profilePicture: imageURLSet?
    
}

struct DummyUserInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct DummyUserResponse: Codable {
    let results: [DummyUser]
    let info: DummyUserInfo
}




// ======================================================= //
// MARK: - Texts
// ======================================================= //

enum TextParagraphLength: String, CaseIterable {
    case short, medium, long, veryLong
}

enum TextOptions: String  {
    case includeLinks = "link"
    case includeUnorderedLists = "ul"
    case includeOrderedLists = "ol"
    case includeDescriptionLists = "dl"
    case includeBlockquotes = "bq"
    case includeCodeSamples = "code"
    case includeHeaders = "headers"
    case allCaps = "allcaps"
    case prude = "prude"
    case html = "html"
}
