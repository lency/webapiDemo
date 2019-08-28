//
//  CommandRouter.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/26.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

struct WebCommandRouter {
    //commanders should split to AOM, BOM, DOM
    //where AOM commander is associatate to app
    //where BOM commander is associatate to an instant of webview, usualy save in the view controller
    //where DOM commander is associatate to an document, usualy save in the view controller, and create when document start, destroy when document is end

    var commanders : [String: WebCommander] = ["webapi": WebapiDemo.share]

    func tryHandle(_ identifier: String, _ cmd: String?, _ executor: @escaping (String) -> ()) -> String? {
        if identifier == "__native__command__" {
            if let dt = cmd,
                let data = dt.data(using: .utf8),
                let cmd = try? JSONDecoder().decode(JSCmdHeader.self, from: data) {
                do {
                    if let commander = commanders[cmd.class] {
                        return try commander.dispatch_ex(cmd.method, cmd.type, data) { executor($0) }
                    }
                    return "{\"type\":\"error\",\"value\":\"api not found\"}"
                } catch {
                    return "{\"type\":\"error\",\"value\":\"\(error.localizedDescription)\"}"
                }
            }
            return "{\"type\":\"error\",\"value\":\"unkown error\"}"
        }
        return nil
    }

    var apiScript: String {
        get {
            return commanders.map { $0.1.jsPiece }.joined()
        }
    }

    static var injectScript : String {
        get {
            return """
            function imp_stub(t,e){function n(t){let e=JSON.stringify(t),n=JSON.parse(prompt("__native__command__",e))||{};if(!(!1 in n)){if("value"==n.type)return n.value;if("error"==n.type)throw n.value;return"promise"==n.type?new Promise(function(t){window[n.promise]=function(e){delete window[n.promise],e=JSON.parse(e),t(e.value)}}):void 0}}function r(t){let e=t.toString();return/\\((.*)\\)/.exec(e)[1].split(",").map(t=>t.trim())}function i(t,e){var n={};for(idx in t)n[t[idx]]=e[idx];return n}let o=Object.getOwnPropertyDescriptors(t.prototype);for(let s in o)if("constructor"!=s){if("value"in o[s]){let p=o[s].value,l=Object.prototype.toString.call(p);l="[object AsyncFunction]"==l?"AsyncFunction":"Function";let c=r(p);t.prototype[s]=function(...t){return n({class:e,method:s,type:l,args:i(c,t)})}}if("get"in o[s]){t.prototype.__lookupGetter__(s);t.prototype.__defineGetter__(s,function(){return n({class:e,type:"Getter",method:s})})}if("set"in o[s]){r(t.prototype.__lookupSetter__(s));t.prototype.__defineSetter__(s,function(t){n({class:e,type:"Setter",method:s,args:{newVal:t}})})}}return new t}class JEventTarget{constructor(){this.listeners=new Map}addEventListener(t,e){this.listeners.set(e.bind(this),{type:t,listener:e})}removeEventListener(t,e){for(let[n,r]of this.listeners)r.type===t&&e===r.listener&&this.listeners.delete(n)}dispatchEvent(t){Object.defineProperty(t,"target",{value:this}),this["on"+t.type]&&this["on"+t.type](t);for(let[e,n]of this.listeners)n.type===t.type&&e(t)}}
            """
        }
    }
}
