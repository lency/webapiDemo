//
//  JSCmdUtil.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

infix operator <+>: AdditionPrecedence

func <+><A,B,C> (_ x: @escaping (A)->B?, _ y: @escaping (B) -> C) -> (A) throws -> C {
    return { (a: A) in
        if let arg = x(a) {
            return y(arg)
        }
        throw JSCmdError.invalidparameters
    }
}

func <+><A,B,C> (_ x: @escaping (A)->B, _ y: @escaping (B) -> C) -> (A) -> C {
    return { (a: A) in
            return y(x(a))
        }
}

func <+><A,B,C> (_ x: @escaping (A) throws ->B, _ y: @escaping (B) -> C) -> (A) throws -> C {
    return { (a: A) in
        let v = try x(a)
        return y(v)
    }
}

struct JsCmdUtil {
    static func toArg<T:Codable>(_ data: Data) -> T? {
        return try? JSONDecoder().decode(JSCmd<T>.self, from: data).args
    }
    static func ToJsValueReturn<T:Encodable>(_ d: T) -> JsValueReturn<T> {
        return JsValueReturn(d)
    }
//    static func toAsyncCall<T>(_ f: JSFuture<T>) -> AsyncCall {
//
//    }
    static func template<T:Codable>(_ fun: @escaping (T) -> JsDone) -> SetterCall{
        return { data in
            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
                return fun(arg)
            }
            throw JSCmdError.invalidparameters
        }
    }

//    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T) -> R) -> SyncCall {
//        return { data in
//            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
//                return JsValueReturn(fun(arg))
//            }
//            throw JSCmdError.invalidparameters
//        }
//    }

    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T) -> R) -> SyncCall {
        return toArg <+> fun <+> ToJsValueReturn
    }

    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T, @escaping (R)->()) -> ()) -> AsyncCall {
        return { (data, b) in
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
        return { (data, b) in
            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
                fun(arg).then { (v: R?) in
                    if let v = v {
                        try? b(JsValueReturn(v))
                    }
                }
                return
            }
            throw JSCmdError.invalidparameters
        }
    }
    static func template<T:Codable, R:Encodable>(_ fun: @escaping (T) -> JSFuture<R>) -> FutureCall {
        return toArg <+> fun
//
//        return { (data, b) in
//            if let arg = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
//                fun(arg).then { (v: R?) in
//                    if let v = v {
//                        try? b(JsValueReturn(v))
//                    }
//                }
//                return
//            }
//            throw JSCmdError.invalidparameters
//        }
    }
}
