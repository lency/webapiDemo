//
//  JSFuture.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/23.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

protocol EncodableFuture {
    func then (_ deal: @escaping (Encodable) -> ())
}

class JSFuture<T> {
    typealias Callback = (T?) -> ()
    var value: T? {
        willSet {
            if let deal = deal {
                deal(newValue)
            }
            deal = nil
        }
    }
    enum State {
        case Init
        case OK
    }
    var state: State = .Init
    private var deal : Callback?
    func then (_ deal: @escaping Callback) {
        if state == .OK {
            deal(value)
        } else {
            self.deal = deal
        }
    }

}

extension JSFuture : EncodableFuture where T: Encodable {
    func then (_ deal: @escaping (Encodable) -> ()) {
        if state == .OK {
            deal(value)
        } else {
            self.deal = deal
        }
    }

}
