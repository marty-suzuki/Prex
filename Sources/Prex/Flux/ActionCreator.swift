//
//  ActionCreator.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public protocol ActionCreator {
    associatedtype Action: Prex.Action
    func dispatch(action: Action)
}
