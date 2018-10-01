//
//  Store.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

internal final class Store<State: Prex.State> {

    internal private(set) var state: State {
        set {
            defer { lock.unlock() }; lock.lock()
            _state = newValue
        }
        get {
            defer { lock.unlock() }; lock.lock()
            return _state
        }
    }

    private var _state: State {
        didSet {
            changed(ValueChange(new: _state, old: oldValue))
        }
    }

    private let changed: (ValueChange<State>) -> ()
    private let lock: NSLocking = NSRecursiveLock()
    private lazy var subscription: Subscription = { fatalError("subscription has not initialized yet") }()

    deinit {
        subscription.cancel()
    }

    internal init<Action, Mutation: Prex.Mutation>(dispatcher: Dispatcher<Action>, state: State, mutation: Mutation, changed: @escaping (ValueChange<State>) -> ()) where Action == Mutation.Action, State == Mutation.State {
        self._state = state
        self.changed = changed
        self.subscription = dispatcher.register { [mutation, weak self] action in
            guard let me = self else {
                return
            }
            mutation.mutate(action: action, state: &me.state)
        }
    }
}
