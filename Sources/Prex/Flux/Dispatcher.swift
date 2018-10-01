//
//  Dispatcher.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

public final class Dispatcher<Action: Prex.Action> {
    private let pubsub = PubSub<Action>()

    internal init() {}

    public func register(handler: @escaping (Action) -> ()) -> Subscription<Action> {
        let token = pubsub.subscribe(handler)
        return Subscription(token: token)
    }

    public func unregister(_ subscription: Subscription<Action>) {
        pubsub.unsubscribe(subscription.token)
    }

    public func dispatch(_ action: Action) {
        pubsub.publish(action)
    }
}
