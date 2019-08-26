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
            function imp_stub(api, name) {
            function npccall(order) {
            let s = JSON.stringify(order);
            let ret = JSON.parse(prompt("__native__command__", s)) || {};
            if (!"type" in ret) return;
            if (ret.type == "value") return ret.value;
            if (ret.type == "error") throw ret.value;
            if (ret.type == "promise")
            return new Promise(function(reslove) {
            window[ret.promise] = function(value) {
            delete window[ret.promise];
            value = JSON.parse(value);
            reslove(value.value);
            };
            });
            }

            function extract_args(fun) {
            let x = fun.toString();
            return /\\((.*)\\)/
            .exec(x)[1]
            .split(",")
            .map(e => e.trim());
            }
            function zip_paras(keys, vals) {
            var obj = {};
            for (idx in keys) obj[keys[idx]] = vals[idx];
            return obj;
            }
            //enumarator
            let descs = Object.getOwnPropertyDescriptors(api.prototype);
            for (let pp in descs) {
            if (pp == "constructor") continue;
            if ("value" in descs[pp]) {
            let x = descs[pp]["value"];
            let type = Object.prototype.toString.call(x);
            if (type == '[object AsyncFunction]') type = 'AsyncFunction'
            else type = 'Function'
            let keys = extract_args(x);
            api.prototype[pp] = function(...args) {
            let s = {
            class: name,
            method: pp,
            type: type,
            args: zip_paras(keys, args)
            };
            return npccall(s);
            };
            }
            if ("get" in descs[pp]) {
            let x = api.prototype.__lookupGetter__(pp);
            api.prototype.__defineGetter__(pp, function() {
            let s = {
            class: name,
            type:"Getter",
            method: pp
            };
            return npccall(s);
            });
            }
            if ("set" in descs[pp]) {
            let x = api.prototype.__lookupSetter__(pp);
            let keys = extract_args(x);
            api.prototype.__defineSetter__(pp, function(v) {
            let s = {
            class: name,
            type:"Setter",
            method: pp,
            args: { newVal: v }
            };
            npccall(s);
            });
            }
            }
            return new api();
            }

            class JEventTarget {
            constructor() {
            this.listeners = new Map();
            }
            addEventListener(type, listener) {
            this.listeners.set(listener.bind(this), {
            type, listener
            });
            }
            removeEventListener(type, listener) {
            for(let [key, value] of this.listeners){
            if(value.type !== type || listener !== value.listener){
            continue;
            }
            this.listeners.delete(key);
            }
            }
            dispatchEvent(event) {
            Object.defineProperty(event, 'target',{value: this});
            this['on' + event.type] && this['on' + event.type](event);
            for (let [key, value] of this.listeners) {
            if (value.type !== event.type) {
            continue;
            }
            key(event);
            }
            }
            }
            """
        }
    }
}
