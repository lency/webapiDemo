//
//  ViewController.swift
//  webapiDemo
//
//  Created by jichuanguo on 2019/8/21.
//  Copyright © 2019 jicg. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    //commanders should split to AOM, BOM, DOM
    //where AOM commander is associatate to app
    //where BOM commander is associatate to an instant of webview, usualy save in the view controller
    //where DOM commander is associatate to an document, usualy save in the view controller, and create when document start, destroy when document is end
    var commanders : [String: WebCommander] = ["webapi": WebapiDemo.share]
    weak var webview : WKWebView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let v = createwebview(wkconfig(loadScript()))
        v.frame = view.frame
        view.addSubview(v)
        loadContent(v)
        v.navigationDelegate = self
        v.uiDelegate = self
        webview = v
        NotificationCenter.default.addObserver(self, selector: #selector(onNoti), name: nil, object: WebapiDemo.share)
    }
    @objc
    func onNoti(_ noti: Notification) {
        let s = "webapi.dispatchEvent(new CustomEvent('\(noti.name.rawValue)', webapi))"
        webview?.evaluateJavaScript(s, completionHandler: nil)
        
    }

    func createwebview(_ config: WKWebViewConfiguration) -> WKWebView {
        return WKWebView(frame: .zero, configuration: config)
    }
    
    func loadContent(_ webview: WKWebView) {
        if let url = Bundle.main.url(forResource: "demo", withExtension: "html") {
            webview.load(URLRequest(url: url))
        }
    }
    
    func wkconfig(_ s: String) -> WKWebViewConfiguration {
        let x = WKWebViewConfiguration()
        
        let script = WKUserScript(source: s,
                                  injectionTime: .atDocumentStart,// 在载入时就添加JS
            forMainFrameOnly: true) // 只添加到mainFrame中
        
        x.userContentController.addUserScript(script)
        return x
    }
    
    func loadScript() -> String {
        do {
            let p = Bundle.main.url(forResource: "inj", withExtension: "js")
            let s = try Data(contentsOf: p!)
            let ss = String(data: s, encoding: .utf8)
            return ss!
        } catch {
            return error.localizedDescription
        }
    }
}

extension ViewController : WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let x = UIAlertController(title: "wk", message: message, preferredStyle: .alert)
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(x, animated: true, completion: nil)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if prompt == "__native__command__" {
            let ret = "{\"type\":\"error\",\"value\":23}"
            if let dt = defaultText,
                let data = dt.data(using: .utf8),
                let cmd = try? JSONDecoder().decode(JSCmdHeader.self, from: data) {
                var ret1 : String?
                do {
                    if let commander = commanders[cmd.class] {
                        ret1 = try commander.dispatch_ex(cmd.method, cmd.type, data) { (s : String) in
                            webView.evaluateJavaScript(s, completionHandler: nil)
                        }
                        completionHandler(ret1)
                        return
                    }
                    completionHandler(ret)
                } catch {
                    completionHandler(ret)

                }
            }
            return
        }
        
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) -> Void in
            textField.textColor = UIColor.red
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
            completionHandler(alert.textFields![0].text!)
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController : WKNavigationDelegate {
    
}

