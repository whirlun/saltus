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
    init() {
        let modifier = Modifier(target: .paragraphs) {
            html, markdown in
            let host = ApplicationData.applicationData.plugin_host
            let plugin_marker = /(\{%){1}\s*(.*)(%\}){1}\s*((.|\n)*)\{%\s*end\s*%\}/
            let markdown_str = String(markdown)
            do {
                if let match = try plugin_marker.firstMatch(in: markdown_str) {
                    if let plugin_result = host.call_plugin_hook(hook: "editor_paragraph", name: String(match.2), hook_val: String(match.4)) {
                        return plugin_result
                    }
                }
            } catch {
                print("\(error)")
            }
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


