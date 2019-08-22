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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let v = createwebview(wkconfig(loadScript()))
        v.frame = view.frame
        view.addSubview(v)
        loadContent(v)
        v.navigationDelegate = self
        v.uiDelegate = self
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
var gd:String = "app"
extension ViewController : WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let x = UIAlertController(title: "wk", message: message, preferredStyle: .alert)
        x.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(x, animated: true, completion: nil)
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if prompt == "__native__command__" {
            let ret = "{\"type\":\"value\",\"value\":23}"
            if let dt = defaultText,
                let data = dt.data(using: .utf8),
                let cmd = try? JSONDecoder().decode(JSCmdHeader.self, from: data) {
                var ret1 : JsReturn?
                do {
                    if cmd.class == "webapi" {
                        ret1 = try webapi.dispatch(cmd.method, data)
                        let data = try JSONEncoder().encode(ret)
                        let str = String(data: data, encoding: .utf8)
                        completionHandler(str)
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
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController : WKNavigationDelegate {
    
}

struct Promise<T:Encodable> : Encodable {
    let future : String
    func coming(_ v: T) {
        
    }
}

class JsReturn : Encodable{
    let type: String
    init(_ type: String) {
        self.type = type
    }
}

class JsValueReturn<T: Encodable> : JsReturn {
    let value: T
    init(_ value: T) {
        self.value = value
        super.init("value")
    }
}

class JsPromiseReturn : JsReturn {
    let promise: String
    override init(_ promise: String) {
        self.promise = promise
        super.init("promise")
    }
}



struct JSCmdHeader : Codable {
    let `class`: String
    let method: String
}

struct JSCmd<T:Codable> : Codable {
    let `class`: String
    let method: String
    let args: T
}

enum JSCmdError : Error {
    case invalidparameters
}

struct webapi {
    static func dispatch(_ method: String, _ json: Data) throws -> JsReturn {
        if method == "hime" {
            
        } else if method == "tims" {
            
        } else if method == "get_x" {
            
        } else if method == "set_x" {
            
        }
        
        return JsValueReturn(10)
    }
    static func tims(_ json: String) throws -> Int {
        struct Arg: Codable {
            let obj1 : Int
            let obj2 : Int
        }
        typealias Result = Int
        
        var ret : Result
        if let data = json.data(using: .utf8),
            let arg = try? JSONDecoder().decode(JSCmd<Arg>.self, from: data).args {
                return tims(arg.obj1, arg.obj2)
        }
        throw JSCmdError.invalidparameters
    }
    private static func tims(_ a1: Int, _ a2: Int) -> Int {
        return a1 * a2
    }
}
