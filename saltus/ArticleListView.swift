////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import CoreData

struct ArticleListView: View {
    @EnvironmentObject var data: ApplicationData
    @Environment(\.managedObjectContext) var dbContext
    @ObservedObject var article_list: ArticleListObserver
    var body: some View {
        VStack {
            List(selection: $data.selected_article) {
                ForEach(article_list.content) {
                    item in
                    Text(item.title ?? "")
                        .tag(item.title)
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

class ArticleListObserver: ObservableObject {
    @Published var content: [Article] = []
    func updateContent(articles: [Article]) {
        self.content = articles
    }
}
