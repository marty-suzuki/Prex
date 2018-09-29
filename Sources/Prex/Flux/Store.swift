//
//  Store.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

internal final class Store<Mutation: Prex.Mutation> {
    internal typealias Action = Mutation.Action
    internal typealias State = Mutation.State

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

    internal init(dispatcher: Dispatcher<Action>, state: State, mutation: Mutation, changed: @escaping (ValueChange<State>) -> ()) {
        self._state = state
        self.changed = changed
        self.subscription = dispatcher.register { [mutation, weak self] action in
            guard let self = self else {
                return
            }
            mutation.mutate(action: action, state: &self.state)
        }
    }
}
