////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI

struct Message: Codable {
    let type: String
    let id: String
    let title: String
    let content: String
}

class JsonMessageHandler {
    @ObservedObject var data: ApplicationData
    
    init(data: ApplicationData) {
        self.data = data
    }
    func handle(msg: String) {
        if let json = decodeJson(msg: msg) {
            switch json.type {
                case "change":
                data.updateArticle(id: json.id, title: json.title, content: json.content)
                default:
                    return
            }
        }
    }
    
    private func decodeJson(msg: String) -> Message? {
        do {
            let json = try JSONDecoder().decode(Message.self, from: msg.data(using: .utf8)!)
            return json
        } catch {
            print(error)
        }
        return nil
    }
}
