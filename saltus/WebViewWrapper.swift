////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import SwiftUI
import WebKit

//from https://stackoverflow.com/questions/43170736/wkwebview-evaluatejavascript-not-returning-html

final class WebViewWrapper: NSObject, NSViewRepresentable, WKNavigationDelegate, WKScriptMessageHandler {
    typealias NSViewControllerType = WKWebView
    lazy var data: ApplicationData = ApplicationData.applicationData
    public var webView: WKWebView {
        get{
            _webView
        }
    }
    
    private var _webView: WKWebView!
    
    override init() {
        super.init()
        let contentController = WKUserContentController()
        contentController.add(self, name: "WebViewMessageHandler")
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = webpagePreferences
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.configuration.preferences.isElementFullscreenEnabled = true
        self._webView = webView
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func evaluateJavascript(_ javascript: String, sourceURL: String? = nil, completion: ((_ error: String?) -> Void)? = nil) {
            var javascript = javascript

            // Adding a sourceURL comment makes the javascript source visible when debugging the simulator via Safari in Mac OS
            if let sourceURL = sourceURL {
                javascript = "//# sourceURL=\(sourceURL).js\n" + javascript
            }

            webView.evaluateJavaScript(javascript) { _, error in
                completion?(error?.localizedDescription)
            }
        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                /*webView.evaluateJavaScript(
                        """
                        webkit.messageHandlers.WebViewMessageHandler.postMessage("Hello");
                        """)*/
        }
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handler = JsonMessageHandler(data: data)
        let body = message.body
        //print(body)
        handler.handle(msg: body as? String ?? "")
    }
    
    func makeNSView(context: Context) -> some NSView {
        webView
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
    
}
