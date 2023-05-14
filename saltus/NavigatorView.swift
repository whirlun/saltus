////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI

enum Target {
    case folder, article
}

struct SplitView: View {
    @EnvironmentObject var data: ApplicationData
    @Binding var item_input: String
    @State var folder_popover_display: Bool = false
    @State var article_popover_display: Bool = false
    @State var article_list_observer = ArticleListObserver()
    var body: some View {
        NavigationSplitView(sidebar: {
            FolderListView()
                .toolbar(content: {
                    Button(action: {folder_popover_display = true}, label: {Image(systemName: "plus")})
                        .popover(isPresented: $folder_popover_display, arrowEdge: .bottom) {
                            AddPopoverView(item_input: $item_input, article_popover_display: $article_popover_display, folder_popover_display: $folder_popover_display, article_list_observer: $article_list_observer, target: .folder).padding()
                        }
                })
                .onChange(of: data.selected_folder, perform: {
                    _ in
                    data.content_observer.changeContent(id: CONSTANT.EMPTYUUID, title: "", content: "")
                })
        },
                            content: {
            ArticleListView(article_list: article_list_observer)
                .onChange(of: data.selected_folder ?? UUID(), perform:{
                    _ in
                    article_list_observer.updateContent(articles: data.getArticlesByFolder(id: data.selected_folder) ?? [])
                })
                .toolbar(content: {
                    Text("preview")
                    Toggle("preview", isOn: $data.preview_mode).toggleStyle(.switch)
                    Button(action: {article_popover_display = true}, label: {Image(systemName: "plus")})
                        .popover(isPresented: $article_popover_display, arrowEdge: .bottom) {
                            AddPopoverView(item_input: $item_input, article_popover_display: $article_popover_display, folder_popover_display: $folder_popover_display,  article_list_observer: $article_list_observer, target: .article).padding()
                        }
                    Button(action: {
                        data.right_bar = !data.right_bar
                    }, label: {Image(systemName: "menucard")})
                    //Button(action: {data.deleteAllArticle()}, label: {Image(systemName: "xmark.bin.fill")})
                })
            
        }, detail: {
            if let selected_item = data.selected_article {
                if let article = data.getArticleById(id: selected_item) {
                    let _ = data.content_observer.changeContent(id: selected_item!.uuidString, title: article.title!, content: article.content!)
                }
            }
            EditorView()
        })
    }
}

struct AddPopoverView: View {
    @Binding var item_input: String
    @Binding var article_popover_display: Bool
    @Binding var folder_popover_display: Bool
    @Binding var article_list_observer: ArticleListObserver
    @EnvironmentObject var data: ApplicationData
    @State var target: Target
    var body: some View {
        TextField("", text: $item_input)
            .frame(width: 150)
        if target == .article {
            Button(action: {
                Task {
                    await data.storeArticle(title:item_input, content:"")
                    article_popover_display = false
                    article_list_observer.updateContent(articles: data.getArticlesByFolder(id: data.selected_folder) ?? [])
                }
            }, label: {Text("Insert")})
            .keyboardShortcut("s")
        } else if target == .folder {
            Button(action: {
                Task {
                    await data.storeFolder(name: item_input)
                    folder_popover_display = false
                    
                }
            }, label: {Text("Insert")})
        }
    }
}

