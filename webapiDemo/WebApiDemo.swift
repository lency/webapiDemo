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

    struct Arg: Codable {
        let obj1 : Int
        let obj2 : Int
    }
    private static func times1(_ args: Arg) -> Int {
        return args.obj1 * args.obj2
    }

    struct Arg1: Codable {
        let seconds : Int
    }

    private static func waitAndAdd(_ args: Arg1, b: @escaping (Int) -> () ) {

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(args.seconds)) {
            b(args.seconds + 1)
        }
    }

    private static func waitAndAdd2(_ args: Arg1) -> JSFuture<Int> {
        let f = JSFuture<Int>()
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(args.seconds)) {
            f.value = args.seconds + 1
        }
        return f
    }

    func trigger(_ : Data) throws -> Encodable {
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
            //return WebapiDemo.waitAndAdd
            return JsCmdUtil.template(WebapiDemo.waitAndAdd2)
        }
        throw JSCmdError.methodnotfound
    }

    func get_sync_pointer(_ method: String) throws -> SyncCall {
        if method == "times" {
            return JsCmdUtil.template(WebapiDemo.times1)
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
