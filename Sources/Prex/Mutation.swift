//
//  Mutation.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public protocol Mutation {
    associatedtype Action: Prex.Action
    associatedtype State: Prex.State

    func mutate(action: Action, state: inout State)
}
