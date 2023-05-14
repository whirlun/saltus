////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI

struct ContentView: View {
    @State private var title = "TODO List"
    @StateObject private var data = ApplicationData.applicationData
    @State private var item_input = ""
    @State private var key_input = "s"
    @State private var key_binding = KeyEquivalent("s")
    var body: some View {
        VStack {
            HStack {
                let _ = test_mruby()
                SplitView(item_input: $item_input)
                    .environmentObject(data)
                    .environment(\.managedObjectContext, data.container.viewContext)
                if data.right_bar {
                    CardView()
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            
    }
}
