//
//  ActionCreator.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public struct ActionCreator<Action: Prex.Action> {

    internal let dispatcher: Dispatcher<Action>

    public init(dispatcher: Dispatcher<Action>) {
        self.dispatcher = dispatcher
    }

    public func dispatch(action: Action) {
        dispatcher.dispatch(action: action)
    }
}
