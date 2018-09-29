//
//  Dispatcher.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public final class Dispatcher<Action: Prex.Action> {

    internal var handler: ((Action) -> ())?

    public init() {}

    public func dispatch(action: Action) {
        handler?(action)
    }
}
