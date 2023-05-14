////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import WebView
import Ink
struct EditorView: View {
    @EnvironmentObject var data: ApplicationData
    @Environment(\.scenePhase) var scenePhase
    var parser = MarkdownParser()
    let host = PluginHost()
    init() {
        let modifier = Modifier(target: .paragraphs) {
            html, markdown in
            print(markdown)
            return html
        }
        parser.addModifier(modifier)
    }
    var body: some View {
        HStack {
            WebView(webView: data.webViewStore.webView)
        }.onAppear(perform: {
            let html = Bundle.main.url(forResource: "index", withExtension: "html")
            self.data.webViewStore.webView.load(URLRequest(url: html!))
            if !data.preview_mode {
                self.data.webViewStore.webView.evaluateJavaScript("onMessage('\(data.content_observer.content.toJsonString ?? "")')\n")
            } else {
                let html = parser.html(from: data.content_observer.content["content"] ?? "")
                let v = ["mode": "viewer", "html": html]
                self.data.webViewStore.webView.evaluateJavaScript("onMessage('\(v.toJsonString ?? "")')\n")
            }
        })
        .onReceive(data.content_observer.$content, perform: {
            _ in
            if !data.preview_mode {
                self.data.webViewStore.webView.evaluateJavaScript("onMessage('\(data.content_observer.content.toJsonString ?? "")')\n")
            } else {
                let html = parser.html(from: data.content_observer.content["content"] ?? "")
                let v = ["mode": "viewer", "html": html]
                self.data.webViewStore.webView.evaluateJavaScript("onMessage('\(v.toJsonString ?? "")')\n")
            }
        })
    }
}

class ArticleContentObserver: ObservableObject {
    @Published var content: [String: String] = [:]
    func changeContent(id: String, title: String, content: String) {
        self.content = ["mode": "editor", "id": id, "title": title, "content": content]
    }
}
