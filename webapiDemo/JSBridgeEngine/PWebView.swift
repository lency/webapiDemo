//
//  CAWebView.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/26.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation
import WebKit

class PWebView : WKWebView {
    private var rlDelegate: WKUIDelegate?
    let router = WebCommandRouter()

    override var uiDelegate: WKUIDelegate? {
        set {
            if newValue !== self {
                rlDelegate = newValue
            } else {
                super.uiDelegate = self
            }
        }
        get {
            return self
        }
    }
    func loadapiStub() {
        let script = WKUserScript(source: router.apiScript,
                                  injectionTime: .atDocumentStart,// 在载入时就添加JS
            forMainFrameOnly: false) // 只添加到mainFrame中
        self.configuration.userContentController.addUserScript(script)
    }
}

extension PWebView : WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if nil == rlDelegate?.webView?(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler) {
            let x = UIAlertController(title: frame.request.url?.host ?? "webkit", message: message, preferredStyle: .alert)
            x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            if nil == closedVC()?.present(x, animated: true, completion: {
                completionHandler()
            }) {
                completionHandler()
            }
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if let ret = router.tryHandle(prompt, defaultText, { [weak webView] (s: String) in
            webView?.evaluateJavaScript(s, completionHandler: nil)
        }) {
            completionHandler(ret)
            return
        }

        if nil == rlDelegate?.webView?(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler) {
            let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)

            alert.addTextField { (textField: UITextField) -> Void in
                textField.textColor = UIColor.red
            }
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                completionHandler(alert.textFields![0].text!)
            }))

            if nil == closedVC()?.present(alert, animated: true, completion: nil) {
                completionHandler("")
            }
        }
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if nil == rlDelegate?.webView?(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler) {
            let x = UIAlertController(title: frame.request.url?.host ?? "webkit", message: message, preferredStyle: .alert)
            x.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(true)
            }))
            x.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
                completionHandler(false)
            }))

            if nil == closedVC()?.present(x, animated: true, completion: nil) {
                completionHandler(false)
            }
        }
    }
}

extension UIResponder {
    func closedVC() -> UIViewController? {
        if self is UIViewController {
            return self as? UIViewController
        }
        return next?.closedVC()
    }
}
