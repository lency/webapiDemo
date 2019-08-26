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

    let router = WebCommandRouter()
    
    weak var webview : WKWebView?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let v = PWebView.createBridgeWebView()
        v.frame = view.frame
        view.addSubview(v)
        loadContent(v)
         webview = v
    }

    func loadContent(_ webview: WKWebView) {
        if let url = Bundle.main.url(forResource: "demo", withExtension: "html") {
            webview.load(URLRequest(url: url))
        }
    }
}

