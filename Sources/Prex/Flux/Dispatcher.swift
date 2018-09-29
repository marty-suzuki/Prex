//
//  Dispatcher.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

public final class Dispatcher<Action: Prex.Action> {
    public typealias Handler = (Action) -> ()

    private let lock: NSLocking = NSRecursiveLock()
    private var next: UInt = 0
    private var handlers: [UInt: Handler] = [:]

    deinit {
        defer { lock.unlock() }; lock.lock()
        handlers.removeAll()
    }

    public init() {}

    public func register(handler: @escaping Handler) -> Subscription {
        defer { lock.unlock() }; lock.lock()
        next += 1
        handlers[next] = handler
        return Subscription(dispatcher: self, key: next)
    }

    public func unregister(_ subscription: Subscription) {
        defer { lock.unlock() }; lock.lock()
        handlers.removeValue(forKey: subscription.key)
    }

    public func dispatch(_ action: Action) {
        defer { lock.unlock() }; lock.lock()
        handlers.forEach { $0.value(action) }
    }
}

public struct Subscription {
    
    fileprivate let key: UInt
    private let dispatcher: _AnyDispatcher

    fileprivate init<Action: Prex.Action>(dispatcher: Dispatcher<Action>, key: UInt) {
        self.dispatcher = _AnyDispatcher(dispatcher)
        self.key = key
    }

    public func cancel() {
        dispatcher.unregister(self)
    }
}

extension Subscription {
    private struct _AnyDispatcher {
        private let _unregister: (Subscription) -> ()

        init<Action: Prex.Action>(_ dispatcher: Dispatcher<Action>) {
            self._unregister = { [weak dispatcher] in dispatcher?.unregister($0) }
        }

        func unregister(_ subscription: Subscription) {
            _unregister(subscription)
        }
    }
}
