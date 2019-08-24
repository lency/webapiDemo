//
//  WebApi.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/22.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

class WebapiDemo : BaseCommand {
    static let share = WebapiDemo()
//properties
    var x : Int?

//sync func time(obj1, obj2)
    struct Arg: Codable {
        let obj1 : Int
        let obj2 : Int
    }
    private static func times(_ args: Arg) -> Int {
        return args.obj1 * args.obj2
    }
//async func waitAndAdd(secconds)
    struct Arg1: Codable {
        let seconds : Int
    }
    private static func waitAndAdd2(_ args: Arg1) -> JSFuture<Int> {
        let f = JSFuture<Int>()
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(args.seconds)) {
            f.value = args.seconds + 1
        }
        return f
    }
//sync func trigger without parameter, and start an event
    func trigger(_ : Data) throws -> JsDone {
        genEvents()
        return JsDone()
    }
//this function will make js eventlistener work for some time
    func genEvents() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            if let `self` = self, let x = self.x, x < 16 {
                NotificationCenter.default.post(name: .init("play"), object: self, userInfo: ["value" : x])
                self.x = x + 1
                self.genEvents()
            }
        }
    }

//init calls
    override init() {
        super.init()
        syncCalls = ["times": JsCmdUtil.toArg <+> WebapiDemo.times <+> JsCmdUtil.toJsValueReturn,
                     "trigger": trigger]

        futureCalls = ["waitAndAdd": JsCmdUtil.toArg <+> WebapiDemo.waitAndAdd2]

    }
//specially for setter
    override func get_setter_pointer(_ method: String) throws -> SetterCall {
        if method == "x" {
            return {[weak self] data in
                self?.x = try JSONDecoder().decode(JSCmd<SetVal<Int?>>.self, from: data).args.newVal
                return JsDone()
            }
        }

        throw JSCmdError.methodnotfound
    }
}
