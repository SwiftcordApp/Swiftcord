//
//  WebView.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 19/2/22.
//

import SwiftUI
import WebKit
import os

// MARK: Adapted from: https://stackoverflow.com/a/63055549/13409955

class WebViewModel: ObservableObject {
    @Published var link: String
    @Published var didFinishLoading: Bool = false
    @Published var token: String? = nil
    @Published var pageTitle: String = ""
    
    init(link: String) {
        self.link = link
    }
}

struct WebView: NSViewRepresentable {
    public typealias NSViewType = WKWebView
    @EnvironmentObject var viewModel: WebViewModel

    private let webView: WKWebView = WKWebView()
    
    public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        webView.configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
		let backgroundImageB64: String? = {
			let image = NSImage(named: "LoginBackground")
			guard let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
			let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
			let jpegData = bitmapRep.representation(using: .png, properties: [:])
			return jpegData?.base64EncodedString()
		}()

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
          // Some things can only be styled thru a style since they are dynamically modified
          const s = document.createElement('style');
          s.innerHTML = `
            #app-mount {
              background: url(data:image/gif;base64,\(backgroundImageB64 ?? ""));
              background-size: cover;
              background-position: center;
            }
            form[class*="authBox-"] {
              background-color: rgba(0, 0, 0, .7)!important;
              -webkit-backdrop-filter: blur(24px) saturate(140%);
            }
          `;
          document.body.appendChild(s);
        }
        """
        webView.configuration.userContentController.addUserScript(WKUserScript(source: interceptJS, injectionTime: .atDocumentStart, forMainFrameOnly: false))
        webView.configuration.userContentController.add(EvtHandler(viewModel), name: "tkEvt")
#if DEBUG
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
#endif
        
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
        
        init(_ viewModel: WebViewModel) {
           // Initialise the WebViewModel
           self.viewModel = viewModel
        }
        
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            viewModel.token = message.body as? String
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel
        private let log = Logger(category: "WebViewCoordinator")

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
            log.info("didFinishNavigation")
        }

        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) { }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            let decision: WKNavigationActionPolicy = navigationAction.request.url?.absoluteString == viewModel.link || navigationAction.request.url?.host == "newassets.hcaptcha.com" ? .allow : .cancel
            decisionHandler(decision)
            log.debug("Navigation to \(navigationAction.request.url?.absoluteString ?? "[unknown URL]", privacy: .public) \(decision == .allow ? "allowed" : "cancelled", privacy: .public)")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
