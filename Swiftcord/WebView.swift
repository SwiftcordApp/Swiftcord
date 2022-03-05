//
//  WebView.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import WebKit

// MARK: Adapted from: https://stackoverflow.com/a/63055549/13409955

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false
    @Published var token: String? = nil
    @Published var pageTitle: String
    
    init(link: String) {
        self.link = link
        self.pageTitle = ""
    }
}

struct WebView: NSViewRepresentable {
    public typealias NSViewType = WKWebView
    @ObservedObject var viewModel: WebViewModel

    private let webView: WKWebView = WKWebView()
    
    public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        let interceptJS = """
        // Get rid of everything in localStorage for a fresh state
        localStorage.clear();
        // Keep a reference to the original localStorage and console.log
        // Discord overwrites/removes both
        let l = localStorage;
        let c = console.log;
        // Remove window localStorage object to allow overwriting it
        delete window.localStorage;
        
        // console.log wrapper with a tag
        const log = (o, s) => c('%c[LocalStorage Shim]%c', 'color:green;font-weight:700', '', o, s);
        
        // Set
        const s = (k, v) => {
          log('SET', k + ' <- ' + v);
          if (k === 'token') window.webkit.messageHandlers.tkEvt.postMessage(JSON.parse(v));
          l[k] = v
        }
        // Get
        const g = k => {
          log('GET', k + ' -> ' + l[k]);
          return l[k];
        }
        
        // Create a new localStorage object with a proxy
        window.localStorage = new Proxy({}, {
          get(target, name) {
            if (name === 'setItem') return s;
            if (name === 'getItem') return g;
            if (name === 'removeItem') return k => {
              log('DELETE', k);
              l.removeItem(k);
            }
            return g(name);
          },
          set(target, k, v) { s(k, v) }
        })
        
        // Also overwrite some styles
        window.onload = () => {
          // Remove the oversaturated background
          document.querySelector('#app-mount > div[class^="app-"] > div:first-child > svg').remove();
          // Remove the fallback Discord logo
          document.querySelector('#app-mount > div[class^="app-"] > div:first-child > a').remove();
          // Make the background less boring
          // Hardcoding for now since there isn't an easy way to get accentColor here
          document.querySelector('#app-mount').style.backgroundImage = 'url("https://preview.redd.it/vda9rbt01en01.png?width=960&crop=smart&auto=webp&s=a669dd6fe1a2f38c08684b43f0253f2dd4d6f9a0")';
        }
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: interceptJS, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        webView.configuration.userContentController.add(EvtHandler(viewModel), name: "tkEvt")
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        
        
        webView.load(URLRequest(url: URL(string: viewModel.link)!))
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebView>) { }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    // Handles the event that's sent from injected JavaScript once the token is available
    class EvtHandler: NSObject, WKScriptMessageHandler {
        private var viewModel: WebViewModel

        init(_ m: WebViewModel) {
            viewModel = m
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            self.viewModel.token = message.body as? String
            print("message: \(message.body)")
            // and whatever other actions you want to take
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel
        private let log = Logger(tag: "WebViewCoordinator")

        init(_ viewModel: WebViewModel) {
           // Initialise the WebViewModel
           self.viewModel = viewModel
        }
        
        public func webView(_: WKWebView, didFail: WKNavigation!, withError: Error) { }

        public func webView(_: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error) { }

        // After the webpage is loaded, assign the data in WebViewModel class
        public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
            self.viewModel.pageTitle = web.title!
            self.viewModel.link = web.url?.absoluteString ?? ""
            self.viewModel.didFinishLoading = true
            log.i("didFinishNavigation")
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let decision: WKNavigationActionPolicy = navigationAction.request.url?.absoluteString == viewModel.link ? .allow : .cancel
            decisionHandler(decision)
            log.d("Navigation to", String(describing: navigationAction.request.url?.absoluteString), decision == .allow ? "allowed" : "cancelled")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
