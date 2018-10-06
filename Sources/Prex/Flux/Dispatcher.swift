//
//  Dispatcher.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

/// Dispatches actions to registerd handlers
public final class Dispatcher<Action: Prex.Action> {
    
    private let pubsub = PubSub<Action>()

    internal init() {}

    /// Registers a actoin dispatch handler
    public func register(handler: @escaping (Action) -> ()) -> Subscription<Action> {
        let token = pubsub.subscribe(handler)
        return Subscription(token: token)
    }

    /// Unregisters a handler with a subscription
    public func unregister(_ subscription: Subscription<Action>) {
        pubsub.unsubscribe(subscription.token)
    }

    /// Dispatches an action
    public func dispatch(_ action: Action) {
        pubsub.publish(action)
    }
}
