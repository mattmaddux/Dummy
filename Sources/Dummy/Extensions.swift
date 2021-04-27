//
//  File.swift
//  
//
//  Created by Matt Maddux on 10/21/20.
//

import Foundation
import SwiftUI

extension CharacterSet {
    /// extracting characters
    /// https://stackoverflow.com/a/52133647/1033581
    public func characters() -> [Character] {
        return codePoints().compactMap { UnicodeScalar($0) }.map { Character($0) }
    }
    public func codePoints() -> [Int] {
        var result: [Int] = []
        var plane = 0
        for (i, w) in bitmapRepresentation.enumerated() {
            let k = i % 8193
            if k == 8192 {
                plane = Int(w) << 13
                continue
            }
            let base = (plane + k) << 3
            for j in 0 ..< 8 where w & 1 << j != 0 {
                result.append(base + j)
            }
        }
        return result
    }

    /// building random string of desired length
    /// https://stackoverflow.com/a/42895178/1033581
    public func randomString(length: Int) -> String {
        let charArray = characters()
        let charArrayCount = UInt32(charArray.count)
        var randomString = ""
        for _ in 0 ..< length {
            randomString += String(charArray[Int(arc4random_uniform(charArrayCount))])
        }
        return randomString
    }
}


extension Image {
    
    static func from(url: URL, placeholderSystemName sysName: String = "photo") -> Image {
        guard let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data) else {
                  return Image(systemName: sysName)
              }
        return Image(uiImage: uiImage)
    }
    
}

extension Date {
    
    static func recent() -> Date {
        let nowSeconds = Date().timeIntervalSince1970
        let oneMonthSeconds = 2592000.00
        let oneMonthAgoSeconds = nowSeconds - oneMonthSeconds
        return Date(timeIntervalSince1970: oneMonthAgoSeconds)
    }
    
    static func recentDates(count: Int) -> [Date] {
        var list = [Date]()
        for _ in 0..<count {
            list.append(Date.recent())
        }
        return list.sorted().reversed()
    }
    
    public var simple: String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        
        if calendar.isDateInToday(self) {
            dateFormatter.dateFormat = "hh:mm a"
            return dateFormatter.string(from: self)
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let string = dateFormatter.string(from: self)
            return string
        }
    }
    
}
