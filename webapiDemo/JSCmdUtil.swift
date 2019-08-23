//
//  JSCmdUtil.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

struct JsCmdUtil {
    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T) -> R) -> SyncCall {
        return { (data: Data) throws -> Encodable in
            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
                return JsValueReturn(fun(arg))
            }
            throw JSCmdError.invalidparameters
        }
    }

    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T, @escaping (R)->()) -> ()) -> AsyncCall {
        return { (data: Data, b: @escaping (Encodable) throws ->()) throws -> () in
            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
                fun(arg) { (v:R) in
                    try? b(JsValueReturn(v))
                }
                return
            }
            throw JSCmdError.invalidparameters
        }
    }

    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T) -> JSFuture<R>) -> AsyncCall {
        return { (data: Data, b: @escaping (Encodable) throws ->()) throws -> () in
            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
                fun(arg).then {(v:R?) in
                    if let v = v {
                        try? b(JsValueReturn(v))
                    }
                }
            }

        }
    }
}
