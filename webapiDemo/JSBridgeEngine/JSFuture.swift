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
    typealias Callback = (T) -> ()
    private var value: T?
    private var deal : Callback?
    func then (_ deal: @escaping Callback) {
        if let value = self.value {
            deal(value)
        } else {
            self.deal = deal
        }
    }
    func succ(_ val: T) {
        if let deal = deal {
            deal(val)
        }
        deal = nil
    }

}

extension JSFuture : EncodableFuture where T: Encodable {
    func then (_ deal: @escaping (Encodable) -> ()) {
        if let value = self.value {
            deal(value)
        } else {
            self.deal = deal
        }
    }
}

extension JSFuture {
    func map<U>(_ op: @escaping (T) -> U) -> JSFuture<U> {
        let future = JSFuture<U>()
        then { future.succ(op($0)) }
        return future
    }

    static func lift<U>(_ op: @escaping (T) -> U) -> (JSFuture<T>) -> JSFuture<U> {
        return {$0.map(op)}
    }
}
