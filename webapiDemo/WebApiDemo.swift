//
//  WebApi.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/22.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation


class WebapiDemo {
    static let share = WebapiDemo()
    var x : Int?

    private static func times(_ data: Data) throws -> Encodable {
        struct Arg: Codable {
            let obj1 : Int
            let obj2 : Int
        }

        if let arg = try? JSONDecoder().decode(JSCmd<Arg>.self, from: data).args {
            return JsValueReturn(times(arg.obj1, arg.obj2))
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
    func trigger(_ data: Data) throws -> Encodable {
        genEvents()
        return JsDone()
    }
    func genEvents() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if let `self` = self, let x = self.x, x < 16 {
                NotificationCenter.default.post(name: .init("play"), object: self, userInfo: ["value" : x])
                self.x = x + 1
                self.genEvents()
            }
        }
    }
}

extension WebapiDemo: WebCommander {
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
        if method == "trigger" {
            return trigger
        }
        throw JSCmdError.methodnotfound
    }

    func get_setter_pointer(_ method: String) throws -> SetterCall {
        if method == "x" {
            return {[weak self] data in
                self?.x = try JSONDecoder().decode(JSCmd<SetVal<Int?>>.self, from: data).args.newVal
            }
        }
        throw JSCmdError.methodnotfound
    }
}
