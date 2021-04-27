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
    public var date: Date
    
}

public protocol DummyData { }

// ======================================================= //
// MARK: - Users
// ======================================================= //

public struct DummyUser: Decodable, Identifiable, DummyData {
    
    // ======================================================= //
    // MARK: - Sub-Types
    // ======================================================= //
    
    public enum Gender: String, Decodable {
        case male, female
    }
    
    public enum Nationality: String, CaseIterable, Decodable {
        case AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NO, NL, NZ, TR, US
    }
    
    public struct Name: Decodable {
        public let title: String?
        public let first: String
        public let last: String
        public var full: String { "\(first) \(last)" }
        
        public init(title: String?, first: String, last: String) {
            self.title = title
            self.first = first
            self.last = last
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: ":").map { String($0) }
            self.title = array[0] != "nil" ? array[0] : nil
            self.first = array[1]
            self.last = array[2]
        }
        
        var string: String { [title ?? "nil", first, last].joined(separator: ":") }
    }
    
    public struct Street: Decodable {
        public let number: Int
        public let name: String
        
        public init(number: Int, name: String) {
            self.number = number
            self.name = name
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: "#").map { String($0) }
            number = Int(array[0])!
            name = array[1]
        }
        
        var string: String { [String(number), name].joined(separator: "#") }
    }
    
    public struct Coordinates: Decodable {
        public let latitude: String
        public let longitude: String
        
        public init(latitude: String, longitude: String) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: "*").map { String($0) }
            latitude = array[0]
            longitude = array[1]
        }
        
        var string: String { [latitude, longitude].joined(separator: "*") }
    }
    
    public struct Timezone: Decodable {
        public let offset: String
        public let description: String
        
        public init(offset: String, description: String) {
            self.offset = offset
            self.description = description
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: "^").map { String($0) }
            offset = array[0]
            description = array[1]
        }
        
        var string: String {
            [offset, description].joined(separator: "^")
        }
    }
    
    public struct Login: Decodable {
        public let uuid: String
        public let username: String
        public let password: String
        public let salt: String
        public let md5: String
        public let sha1: String
        public let sha256: String
        
        public init(uuid: String, username: String, password: String, salt: String, md5: String, sha1: String, sha256: String) {
            self.uuid = uuid
            self.username = username
            self.password = password
            self.salt = salt
            self.md5 = md5
            self.sha1 = sha1
            self.sha256 = sha256
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: ":").map { String($0) }
            self.uuid = array[0]
            self.username = array[1]
            self.password = array[2]
            self.salt = array[3]
            self.md5 = array[4]
            self.sha1 = array[5]
            self.sha256 = array[6]
        }
        
        var string: String { [uuid, username, password, salt, md5, sha1, sha256].joined(separator: ":") }
    }
    
    public struct Age: Decodable {
        public let date: Date
        public let age: Int
        
        public init(date: Date, age: Int) {
            self.date = date
            self.age = age
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: ":").map { String($0) }
            self.date = Date(timeIntervalSince1970: Double(array[0])!)
            self.age = Int(array[1])!
        }
        
        var string: String { [String(date.timeIntervalSince1970), String(age)].joined(separator: ":") }
        
    }
    
    public struct Identification: Decodable {
        public let name: String?
        public let value: String?
        
        public init(name: String?, value: String?) {
            self.name = name
            self.value = value
        }
        
        public init(fromString source: String) {
            let array = source.split(separator: ":").map { String($0) }
            self.name = array[0] != "nil" ? array[0] : nil
            self.value = array[0] != "nil" ? array[0] : nil
        }
        
        var string: String { [name ?? "nil", value ?? "nil"].joined(separator: ":") }
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
        
        public init(fromString source: String) {
            let array = source.split(separator: "!").map { String($0) }
            self.street = Street(fromString: array[0])
            self.city = array[1]
            self.state = array[2]
            self.postcode = array[3]
            self.coordinates = Coordinates(fromString: array[4])
            self.timezone = Timezone(fromString: array[5])
        }
        
        var string: String { [street.string, city, state, postcode, coordinates.string, timezone.string].joined(separator: "!") }
        
        public let street: Street
        public let city: String
        public let state: String
        public let postcode: String
        public let coordinates: Coordinates
        public let timezone: Timezone
        public var address: String { return "\(street.number) \(street.name), \(city), \(state), \(postcode)"}
    }
    
    
    // ======================================================= //
    // MARK: - Decoding
    // ======================================================= //
    
    public enum CodingKeys: String, CodingKey {
        case gender, name, location, email, login, dob, registered, phone, cell, nat, id, picture
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
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
        self.profilePictureData = try? Data(contentsOf: imageSet.large)
        self.storedProfilePicture = nil
    }
    
    public init(gender: Gender, name: Name, location: Location, email: String, login: Login, dob: Age, registered: Age, phone: String, cell: String, identification: Identification, nationality: Nationality, profilePicture: Image) {
        self.id = UUID()
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
        self.storedProfilePicture = profilePicture
        self.profilePictureData = nil
    }
    
    // ======================================================= //
    // MARK: - Properties
    // ======================================================= //
    
    public let id: UUID
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
    public var profilePictureData: Data?
    public let storedProfilePicture: Image?
    public var profilePicture: Image {
        if let profilePictureData = profilePictureData {
            return Image(uiImage: UIImage(data: profilePictureData)!)
        } else if let storedProfilePicture = storedProfilePicture {
            return storedProfilePicture
        } else {
            return Image(systemName: "user")
        }
    }
    
    
    public init(fromDict source: [String:String]) {
        self.id = UUID(uuidString: source["id"]!)!
        self.gender = Gender(rawValue: source["gender"]!)!
        self.name = Name(fromString: source["name"]!)
        self.location = Location(fromString: source["location"]!)
        self.email = source["email"]!
        self.login = Login(fromString: source["login"]!)
        self.dob = Age(fromString: source["dob"]!)
        self.registered = Age(fromString: source["registered"]!)
        self.phone = source["phone"]!
        self.cell = source["cell"]!
        self.identification = Identification(fromString: source["identification"]!)
        self.nationality = Nationality(rawValue: source["nationality"]!)!
        self.profilePictureData = nil
        self.storedProfilePicture = nil
    }
    
    var dict: [String:String] {
        ["id": id.uuidString,
         "gender": gender.rawValue,
         "name": name.string,
         "location": location.string,
         "email": email,
         "login": login.string,
         "dob": dob.string,
         "registered": registered.string,
         "phone": phone,
         "cell": cell,
         "identification": identification.string,
         "nationality": nationality.rawValue]
    }
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

typealias DummySnippet = String

extension DummySnippet: DummyData { }

public enum SnippetParagraphLength: String, CaseIterable {
    case short, medium, long, veryLong = "very long"
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

public struct DummyPhoto: Decodable, Identifiable, DummyData {
    
    
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
    public var imageData: Data?
    public var storedImage: Image?
    public var image: Image {
        if let imageData = imageData {
            return Image(uiImage: UIImage(data: imageData)!)
        } else if let storedImage = storedImage {
            return storedImage
        } else {
            return Image(systemName: "photo")
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        let allSizes = Dictionary(uniqueKeysWithValues:
                                try container.decode(Dictionary<String, String>.self, forKey: .src)
                                    .map()  { ( Size(rawValue: $0)!, URL(string: $1)! ) }
        )
        self.imageData = try? Data(contentsOf: allSizes[.original]!)
        self.storedImage = nil
    }
    
    public init(id: Int, width: Int, height: Int, image: Image) {
        self.id = id
        self.width = width
        self.height = height
        self.storedImage = image
        self.imageData = nil
    }
    
    public init(fromDict dict: [String:String]) {
        self.id = Int(dict["id"]!)!
        self.width = Int(dict["width"]!)!
        self.height = Int(dict["height"]!)!
        self.imageData = nil
        self.storedImage = nil
    }
    
    var dict: [String: String] {
        ["id": String(id),
         "width": String(width),
         "height": String(height)]
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

public struct DummyVideo: Decodable, Identifiable, DummyData {
    
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
    
    public var screenshotData: Data?
    public var storedScreenshot: Image?
    
    public var screenshot: Image {
        if let screenshotData = screenshotData {
            return Image(uiImage: UIImage(data: screenshotData)!)
        } else if let storedScreenshot = storedScreenshot {
            return storedScreenshot
        } else {
            return Image(systemName: "video")
        }
    }
    
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
        self.screenshotData = try? Data(contentsOf: screenshotURL)
        self.storedScreenshot = nil
        
        // Select URL
        let selected = allVersions.first() { $0.quality == .hls } ?? allVersions.max() { $0.height ?? 0 < $1.height ?? 0 }!
        self.url = selected.url
    }
    
    public init(id: Int, width: Int, height: Int, duration: Int, screenshot: Image, url: URL) {
        self.id = id
        self.width = width
        self.height = height
        self.duration = duration
        self.storedScreenshot = screenshot
        self.screenshotData = nil
        
        self.url = url
    }
    
    public init(fromDict dict: [String:String]) {
        self.id = Int(dict["id"]!)!
        self.width = Int(dict["width"]!)!
        self.height = Int(dict["height"]!)!
        self.duration = Int(dict["duration"]!)!
        self.url = URL(string: dict["url"]!)!
        self.screenshotData = nil
        self.storedScreenshot = nil
    }
    
    public var dict: [String: String] {
        ["id": String(id),
         "width": String(width),
         "height": String(height),
         "duration": String(duration),
         "url": url.absoluteString]
    }
    
}
