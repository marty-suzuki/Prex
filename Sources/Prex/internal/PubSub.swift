//
//  PubSub.swift
//  Prex
//
//  Created by marty-suzuki on 2018/10/02.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

final class PubSub<T> {
    public typealias Handler = (T) -> ()

    private let lock: NSLocking = NSRecursiveLock()
    private var next: UInt = 0
    private var handlers: [UInt: Handler] = [:]

    deinit {
        defer { lock.unlock() }; lock.lock()
        handlers.removeAll()
    }

    init() {}

    public func subscribe(_ handler: @escaping Handler) -> Token {
        lock.lock(); defer { lock.unlock() }
        next += 1
        handlers[next] = handler
        return Token(next)
    }

    public func unsubscribe(_ token: Token) {
        lock.lock(); defer { lock.unlock() }
        handlers.removeValue(forKey: token.rawValue)
    }

    func publish(_ topic: T) {
        lock.lock(); defer { lock.unlock() }
        handlers.forEach { $0.value(topic) }
    }
}

struct Token {
    fileprivate let rawValue: UInt
    fileprivate init(_ rawValue: UInt) {
        self.rawValue = rawValue
    }
}
