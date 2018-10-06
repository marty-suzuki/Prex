//
//  Store.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

// MARK: - Store

/// Manages state and mutates state with actions recieved from Dispatcher
public final class Store<State: Prex.State> {

    /// Current state
    public private(set) var state: State {
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
            pubsub.publish(ValueChange(new: _state, old: oldValue))
        }
    }

    private let lock: NSLocking = NSRecursiveLock()
    private let pubsub = PubSub<ValueChange<State>>()
    private let dispatcher: _AnyDispatcher
    private lazy var subscription: _AnySubscription = { fatalError("subscription has not initialized yet") }()

    deinit {
        dispatcher.unregister(subscription)
    }

    internal init<Action, Mutation: Prex.Mutation>(dispatcher: Dispatcher<Action>, state: State, mutation: Mutation) where Action == Mutation.Action, State == Mutation.State {
        self._state = state
        self.dispatcher = _AnyDispatcher(dispatcher)
        let subscription = dispatcher.register { [mutation, weak self] action in
            guard let me = self else {
                return
            }
            mutation.mutate(action: action, state: &me.state)
        }
        self.subscription = _AnySubscription(subscription)
    }


    /// Registers listeners as callback
    ///
    /// - Parameter callback: Notifies changes of state
    public func addListener(callback: @escaping (ValueChange<State>) -> ()) -> Subscription<State> {
        let token = pubsub.subscribe(callback)
        return Subscription<State>(token: token)
    }


    /// Removes listenners with a subscription
    public func removeListener(with subscription: Subscription<State>) {
        pubsub.unsubscribe(subscription.token)
    }
}

// MARK: - Type Erasure

private struct _AnySubscription {
    
    let token: Token

    init<Action: Prex.Action>(_ subscription: Subscription<Action>) {
        self.token = subscription.token
    }
}

private struct _AnyDispatcher {

    private let _unregister: (_AnySubscription) -> ()

    init<Action: Prex.Action>(_ dispatcher: Dispatcher<Action>) {
        self._unregister = { [weak dispatcher] in
            let subscription = Subscription<Action>(token: $0.token)
            dispatcher?.unregister(subscription)
        }
    }

    func unregister(_ subscription: _AnySubscription) {
        _unregister(subscription)
    }
}
