//
//  WebApi.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/22.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation


class WebapiDemo : WebCommander {
    func get_async_pointer(_ method: String) throws -> AsyncCall {
        if method == "waitAndAdd" {
            return WebapiDemo.waitAndAdd
        }
        throw JSCmdError.methodnotfound
    }

    func get_sync_pointer(_ method: String) throws -> SyncCall {
        if method == "times" {
            return WebapiDemo.times
        }
        if method == "get_x" {
            return {[weak self] _ in
                try JSONEncoder().encode( JsValueReturn( self?.x ) )
            }
        }
        throw JSCmdError.methodnotfound
    }

    func get_setter_pointer(_ method: String) throws -> SetterCall {
        if method == "set_x" {
            return {[weak self] data in
                self?.x = try JSONDecoder().decode(JSCmd<SetVal<Int?>>.self, from: data).args.newVal
            }
        }
        throw JSCmdError.methodnotfound
    }

    static let share = WebapiDemo()
    var x : Int?
    func dispatch(_ method: String, _ type: CmdType, _ json: Data, invoker: @escaping (String) -> ()) throws -> String? {
        var data : Data?
        if method == "waitAndAdd" {
            let ck = "_" + String(format: "%x", json.hashValue)
            try WebapiDemo.waitAndAdd(json) {ret in
                invoker("\(ck)(\(ret))")
            }
            data = try JSONEncoder().encode( JsPromiseReturn( ck ) )
        } else if method == "times" {
            data = try WebapiDemo.times(json)
        } else if method == "get_x" {
            data = try JSONEncoder().encode( JsValueReturn( x ) )
        } else if method == "set_x" {
            x = try JSONDecoder().decode(JSCmd<SetVal<Int?>>.self, from: json).args.newVal
        }

        return data.flatMap { String(data: $0, encoding: .utf8) }
    }



    private static func times(_ data: Data) throws -> Data {
        struct Arg: Codable {
            let obj1 : Int
            let obj2 : Int
        }

        if let arg = try? JSONDecoder().decode(JSCmd<Arg>.self, from: data).args {
            return try JSONEncoder().encode( JsValueReturn(times(arg.obj1, arg.obj2)))
        }
        throw JSCmdError.invalidparameters
    }
    private static func times(_ a1: Int, _ a2: Int) -> Int {
        return a1 * a2
    }

    private static func waitAndAdd(_ data: Data , b: @escaping (Int) -> () ) throws {
        struct Arg: Codable {
            let seconds : Int
        }
        if let arg = try? JSONDecoder().decode(JSCmd<Arg>.self, from: data).args {
            waitAndAdd(arg.seconds) {ret in
                b(ret)
            }
            return
        }
        throw JSCmdError.invalidparameters
    }
    private static func waitAndAdd(_ a1: Int, b: @escaping (Int) -> () ) {

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(a1)) {
            b(a1+1)
        }
    }
}
