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
