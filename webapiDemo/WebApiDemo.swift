//
//  WebApi.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/22.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

class WebapiDemo : BaseCommand {
    override var `class`: String { return "webapi" }
    override var jsPiece: String {
        return """
    let webapi = imp_stub(
    class extends JEventTarget {
    times(obj1, obj2) {}
    async waitAndAdd(seconds) {}
    get x() {}
    set x(newVal) {}
    trigger(){}
    },
    "webapi"
    );
    """
    }
    static let share = WebapiDemo()

    //properties
    var x : Int?

//sync func time(obj1, obj2)
    struct Arg: Codable {
        let obj1 : Int
        let obj2 : Int
    }
    private func times(_ args: Arg) -> Int {
        return args.obj1 * args.obj2
    }
//async func waitAndAdd(secconds)
    struct Arg1: Codable {
        let seconds : Int
    }
    private func waitAndAdd2(_ args: Arg1) -> JSFuture<Int> {
        let f = JSFuture<Int>()
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(args.seconds)) {
            f.succ(args.seconds + 1)
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
                self.sendEvent("play")
                self.x = x + 1
                self.genEvents()
            }
        }
    }

    func setX(_ arg: SetVal<Int?>) -> JsDone {
        x = arg.newVal
        return JsDone()
    }
    
//init calls
    override init() {
        super.init()
        syncCalls = ["times": JsCmdUtil.toArg <+> times <+> JsCmdUtil.toJsValueReturn,
                     "trigger": trigger]

        futureCalls = ["waitAndAdd": JsCmdUtil.toArg <+> waitAndAdd2]
        setterCalls = ["x": JsCmdUtil.toArg <+> setX]
    }
}
