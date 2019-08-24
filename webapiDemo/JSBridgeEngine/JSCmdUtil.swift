//
//  JSCmdUtil.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

struct JsCmdUtil {
    static func toArg<T:Codable>(_ data: Data) throws -> T {
        if let args = try? JSONDecoder().decode(JSCmd<T>.self, from: data).args {
            return args
        }
        throw JSCmdError.invalidparameters
    }
    static func toJsValueReturn<T:Encodable>(_ d: T) -> JsValueReturn<T> {
        return JsValueReturn(d)
    }
}

extension Encodable {
    func toWrapperJsonData() throws -> Data {
        return try JSONEncoder().encode(JsValueReturn(self))
    }
}
