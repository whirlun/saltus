////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

struct CONSTANT {
    static let EMPTYUUID = "00000000-0000-0000-0000-000000000000"
}

extension Dictionary {
    var toJsonString: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self) else {
                    return nil
                }
        return String(data: theJSONData, encoding: .utf8)?.escaped
    }
}

//https://stackoverflow.com/questions/34810236/swift-2-0-escaping-string-for-new-line-string-encoding
extension String {
    var escaped: String {
        if let data = try? JSONEncoder().encode(self) {
            let escaped = String(data: data, encoding: .utf8)!
            // Remove leading and trailing quotes
            let set = CharacterSet(charactersIn: "\"")
            return escaped.trimmingCharacters(in: set)
        }
        return self
    }
}
