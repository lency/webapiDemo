//
//  JSBaseCommand.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation


class BaseCommand: WebCommander {
    var asyncCalls: [String: AsyncCall] = [:]
    var syncCalls: [String: SyncCall] = [:]
    var setterCalls: [String: SetterCall] = [:]
    var futureCalls: [String: FutureCall] = [:]

    func get_async_pointer(_ method: String) throws -> AsyncCall {
        if let f = asyncCalls[method] {
            return f
        }
        throw JSCmdError.methodnotfound
    }

    func get_sync_pointer(_ method: String) throws -> SyncCall {
        if let f = syncCalls[method] {
            return f
        }
        throw JSCmdError.methodnotfound
    }
    func get_setter_pointer(_ method: String) throws -> SetterCall {
        if let f = setterCalls[method] {
            return f
        }
        throw JSCmdError.methodnotfound
    }
    func get_future_pointer(_ method: String) throws -> FutureCall {
        if let f = futureCalls[method] {
            return f
        }
        throw JSCmdError.methodnotfound
    }
}
