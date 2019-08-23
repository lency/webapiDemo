//
//  Encoder+Json.swift
//  webapiDemo
//
//  Created by jichuanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

extension Encodable {
    func toJsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    func toWrapperJsonData() throws -> Data {
        return try JSONEncoder().encode(JsValueReturn(self))
    }
}
