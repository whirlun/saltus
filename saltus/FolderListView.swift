////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import CoreData

struct FolderListView: View {
    @EnvironmentObject var data: ApplicationData
    @Environment(\.managedObjectContext) var dbContext
    @FetchRequest(sortDescriptors: []) private var folderList: FetchedResults<Folder>
    var body: some View {
        VStack {
            List(selection: $data.selected_folder) {
                ForEach(folderList) {
                    item in
                    Text(item.name!)
                        .tag(item.name!)
                        .contextMenu {
                            Button(action: {
                                dbContext.delete(item)
                                do {
                                    try dbContext.save()
                                } catch {
                                    print("\(error)")
                                }
                            }, label: {Text("Delete")})
                        }
                }
            }
        }
    }
}
