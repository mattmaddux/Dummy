//
//  File.swift
//  
//
//  Created by Matt Maddux on 10/22/20.
//

import Foundation
import SwiftUI

let previewLocation = DummyUser.Location(street: DummyUser.Street(number: 555, name: "Street St."),
                                         city: "City",
                                         state: "ST",
                                         postcode: "12345",
                                         coordinates: DummyUser.Coordinates(latitude: "40.712776", longitude: "-74.005974"),
                                         timezone: DummyUser.Timezone(offset: "-3:30", description: "Location"))

let previewUser = DummyUser(gender: .female,
                            name: DummyUser.Name(title: nil, first: "First", last: "Last"),
                            location: previewLocation,
                            email: "user@domain.org",
                            login: DummyUser.Login(uuid: UUID().uuidString, username: "username", password: "CSp@UMDcxs", salt: "TQA1Gz7x", md5: "dc523cb313b63dfe5be2140b0c05b3bc", sha1: "7a4aa07d1bedcc6bcf4b7f8856643492c191540d", sha256: "7a4aa07d1bedcc6bcf4b7f8856643492c191540d"),
                            dob: DummyUser.Age(date: Date(), age: 22),
                            registered: DummyUser.Age(date: Date(), age: 3),
                            phone: "011-962-7516",
                            cell: "081-454-0666",
                            identification: DummyUser.Identification(name: "PPS", value: "0390511T"),
                            nationality: .US,
                            profilePicture: Image("profile", bundle: .module))

let previewSnippet = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dolor sit amet consectetur adipiscing elit pellentesque habitant morbi. Morbi tempus iaculis urna id volutpat.
Massa id neque aliquam vestibulum morbi blandit cursus risus. Ut eu sem integer vitae justo eget. Pharetra diam sit amet nisl suscipit. Pretium fusce id velit ut. Placerat vestibulum lectus mauris ultrices. Amet consectetur adipiscing elit pellentesque habitant morbi tristique senectus et.
"""

let previewPhoto = DummyPhoto(id: Int.random(in: 100..<1000),
                              width: 1920,
                              height: 1080,
                              image: Image("photo", bundle: .module))

let previewVideo = DummyVideo(id: Int.random(in: 100..<1000),
                              width: 1920,
                              height: 1080,
                              duration: 60,
                              screenshot: Image("video", bundle: .module),
                              url: URL(string: "https://player.vimeo.com/external/291648067.m3u8?s=1210fac9d80f9b74b4a334c4fca327cde08886b2&oauth2_token_id=57447761")!)

let previewItem = DummyItem(id: UUID(),
                            user: previewUser,
                            snippet: previewSnippet,
                            photo: previewPhoto,
                            video: previewVideo,
                            date: Date.recent())
