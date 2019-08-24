//
//  FPCompose.swift
//  webapiDemo
//
//  Created by jicuhanguo on 2019/8/24.
//  Copyright © 2019 jicg. All rights reserved.
//

import Foundation

infix operator <+>: AdditionPrecedence

func <+><A,B,C> (_ x: @escaping (A) -> B, _ y: @escaping (B) -> C) -> (A) -> C {
    return { y(x($0)) }
}

func <+><A,B,C> (_ x: @escaping (A) throws -> B, _ y: @escaping (B) -> C) -> (A) throws -> C {
    return { y(try x($0)) }
}

func <+><A,B,C> (_ x: @escaping (A) throws -> B, _ y: @escaping (B) throws -> C) -> (A) throws -> C {
    return { try y(try x($0)) }
}

func <+><A,B,C> (_ x: @escaping (A) ->B, _ y: @escaping (B) throws -> C) -> (A) throws -> C {
    return { try y(x($0)) }
}
