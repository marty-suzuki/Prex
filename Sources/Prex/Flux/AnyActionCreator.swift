//
//  AnyActionCreator.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public struct AnyActionCreator<Action: Prex.Action>: ActionCreator {

    private let _dispatch: (Action) -> ()

    internal init<ActionCreator: Prex.ActionCreator>(_ actionCreator: ActionCreator) where ActionCreator.Action == Action {
        self._dispatch = { actionCreator.dispatch(action: $0) }
    }

    public func dispatch(action: Action) {
        _dispatch(action)
    }
}
