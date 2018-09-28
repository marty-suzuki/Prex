//
//  Store.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

open class Store<Mutation: Prex.Mutation> {
    public typealias Action = Mutation.Action
    public typealias State = Mutation.State

    internal private(set) var state: State {
        didSet {
            changed?(ChangedValue(new: state, old: oldValue))
        }
    }

    internal var changed: ((ChangedValue<State>) -> ())?

    public init(dispatcher: Dispatcher<Action>, state: State, mutation: Mutation) {
        self.state = state

        dispatcher.handler = { [mutation, weak self] action in
            guard let self = self else {
                return
            }
            mutation.mutate(action: action, state: &self.state)
        }
    }
}

public struct ChangedValue<T> {
    public let new: T
    public let old: T?
}
