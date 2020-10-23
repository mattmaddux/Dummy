//
//  DummyTypes.swift
//
//  Created by Matt Maddux on 10/13/20.
//

import Foundation
import UIKit
import SwiftUI


// ======================================================= //
// MARK: - DummyElement
// ======================================================= //


public enum DummyElement: CaseIterable {
    case user, snippet, photo, video
}

// ======================================================= //
// MARK: - Dummy Item
// ======================================================= //

public struct DummyItem: Decodable, Identifiable {

    public var id: UUID = UUID()
    public var user: DummyUser
    public var snippet: String
    public var photo: DummyPhoto
    public var video: DummyVideo
    
}

// ======================================================= //
// MARK: - Users
// ======================================================= //

public struct DummyUser: Decodable, Identifiable {
    
    // ======================================================= //
    // MARK: - Sub-Types
    // ======================================================= //
    
    public enum Gender: String, Decodable {
        case male, female
    }
    
    public enum Nationality: String, Decodable {
        case AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NO, NL, NZ, TR, US
    }
    
    public struct Name: Decodable {
        public let title: String?
        public let first: String
        public let last: String
        public var full: String { "\(first) \(last)" }
    }
    
    public struct Street: Decodable {
        public let number: Int
        public let name: String
    }
    
    public struct Coordinates: Decodable {
        public let latitude: String
        public let longitude: String
    }
    
    public struct Timezone: Decodable {
        public let offset: String
        public let description: String
    }
    
    public struct Login: Decodable {
        public let uuid: String
        public let username: String
        public let password: String
        public let salt: String
        public let md5: String
        public let sha1: String
        public let sha256: String
    }
    
    public struct Age: Decodable {
        public let date: Date
        public let age: Int
    }
    
    public struct Identification: Decodable {
        public let name: String?
        public let value: String?
    }
    
    public struct ImageSet: Decodable {
        public let large: URL
        public let medium: URL
        public let thumbnail: URL
    }
    
    public struct Location: Decodable {
        
        public enum CodingKeys: CodingKey {
            case street, city, state, postcode, coordinates, timezone
        }
        
        public init(from decoder: Decoder) throws {
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
        
        public init(street: Street, city: String, state: String, postcode: String, coordinates: Coordinates, timezone: Timezone) {
            self.street = street
            self.city = city
            self.state = state
            self.postcode = postcode
            self.coordinates = coordinates
            self.timezone = timezone
        }
        
        public let street: Street
        public let city: String
        public let state: String
        public let postcode: String
        public let coordinates: Coordinates
        public let timezone: Timezone
    }
    
    
    // ======================================================= //
    // MARK: - Decoding
    // ======================================================= //
    
    public enum CodingKeys: String, CodingKey {
        case gender, name, location, email, login, dob, registered, phone, cell, nat, id, picture
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gender = try container.decode(Gender.self, forKey: .gender)
        self.name = try container.decode(Name.self, forKey: .name)
        self.location = try container.decode(Location.self, forKey: .location)
        self.email = try container.decode(String.self, forKey: .email)
        self.login = try container.decode(Login.self, forKey: .login)
        self.dob = try container.decode(Age.self, forKey: .dob)
        self.registered = try container.decode(Age.self, forKey: .registered)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.cell = try container.decode(String.self, forKey: .cell)
        self.identification = try container.decode(Identification.self, forKey: .id)
        self.nationality = try container.decode(Nationality.self, forKey: .nat)
        let imageSet = try container.decode(ImageSet.self, forKey: .picture)
        self.profilePicture = Image.from(url: imageSet.large)
    }
    
    public init(gender: Gender, name: Name, location: Location, email: String, login: Login, dob: Age, registered: Age, phone: String, cell: String, identification: Identification, nationality: Nationality, profilePicture: Image) {
        self.gender = gender
        self.name = name
        self.location = location
        self.email = email
        self.login = login
        self.dob = dob
        self.registered = registered
        self.phone = phone
        self.cell = cell
        self.identification = identification
        self.nationality = nationality
        self.profilePicture = profilePicture
    }
    
    // ======================================================= //
    // MARK: - Properties
    // ======================================================= //
    
    public let id: UUID = UUID()
    public let gender: Gender
    public let name: Name
    public let location: Location
    public let email: String
    public let login: Login
    public let dob: Age
    public let registered: Age
    public let phone: String
    public let cell: String
    public let identification: Identification
    public let nationality: Nationality
    public let profilePicture: Image
    
}

public struct DummyUserInfo: Decodable {
    public let seed: String
    public let results: Int
    public let page: Int
    public let version: String
}

public struct DummyUserResponse: Decodable {
    public let results: [DummyUser]
    public let info: DummyUserInfo
}




// ======================================================= //
// MARK: - Snippets
// ======================================================= //

public enum SnippetParagraphLength: String, CaseIterable {
    case short, medium, long, veryLong
}

public enum SnippetOptions: String  {
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


// ======================================================= //
// MARK: - Photos
// ======================================================= //


public struct DummyPhotoResponse: Decodable {
    
    public let page: Int
    public let perPage: Int
    public let photos: [DummyPhoto]
    public let nextPage: URL
    
    
    enum CodingKeys: String, CodingKey {
        case page, photos
        case perPage = "per_page"
        case nextPage = "next_page"
    }
    
}

public struct DummyPhoto: Decodable, Identifiable {
    
    
    public enum Size: String, Decodable, CaseIterable {
        case original, large2x, large, medium, small, portrait, landscape, tiny
        
        var next: Size {
            let all = Size.allCases
            let nextIndex = all.firstIndex(of: self)! + 1
            return nextIndex < all.count ? all[nextIndex] : all[0]
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, src
    }
    
    public let id: Int
    public let width: Int
    public let height: Int
    public let image: Image
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        let allSizes = Dictionary(uniqueKeysWithValues:
                                try container.decode(Dictionary<String, String>.self, forKey: .src)
                                    .map()  { ( Size(rawValue: $0)!, URL(string: $1)! ) }
        )
        self.image = Image.from(url: allSizes[.original]!)
    }
    
    public init(id: Int, width: Int, height: Int, image: Image) {
        self.id = id
        self.width = width
        self.height = height
        self.image = image
    }

}



// ======================================================= //
// MARK: - Videos
// ======================================================= //

public struct DummyVideoResponse: Decodable {
    
    public enum CodingKeys: String, CodingKey {
        case page, videos
        case resultCount = "total_results"
        case perPage = "per_page"
    }
    
    public let resultCount: Int
    public let page: Int
    public let perPage: Int
    public let videos: [DummyVideo]
    
}

public struct DummyVideo: Decodable {
    
    public struct Version: Decodable {
        
        public enum Quality: String, Decodable {
            case hls, hd, sd
        }
        
        public enum CodingKeys: String, CodingKey {
            case id, quality, width, height
            case type = "file_type"
            case url = "link"
        }
        
        public let id: Int
        public let quality: Quality
        public let type: String
        public let width: Int?
        public let height: Int?
        public let url: URL
        
        
        
    }
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, duration, image, video_files
    }

    public let id: Int
    public let width: Int
    public let height: Int
    public let duration: Int
    public var screenshot: Image
    public var url: URL
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.duration = try container.decode(Int.self, forKey: .duration)
        let screenshotURL = try container.decode(URL.self, forKey: .image)
        let allVersions = try container.decode([Version].self, forKey: .video_files)
        
        // Get Image
        self.screenshot = Image.from(url: screenshotURL)
        
        // Select URL
        let selected = allVersions.first() { $0.quality == .hls } ?? allVersions.max() { $0.height ?? 0 < $1.height ?? 0 }!
        self.url = selected.url
    }
    
    public init(id: Int, width: Int, height: Int, duration: Int, screenshot: Image, url: URL) {
        self.id = id
        self.width = width
        self.height = height
        self.duration = duration
        self.screenshot = screenshot
        self.url = url
    }
    
}
