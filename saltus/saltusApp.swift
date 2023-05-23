////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI

@main
struct saltusApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
            }
        }.commands {
            CommandMenu("Plugins") {
                Button("Open Plugin Directory") {
                    let manager = FileManager.default
                    let application_support = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                    let directory = application_support?.appending(path: "zip.ddc.saltus/plugins")
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: directory!.path(percentEncoded: true))
                }
            }
        }
    }
}
