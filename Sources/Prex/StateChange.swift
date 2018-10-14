//
//  StateChange.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

/// Contains new and old value
public struct StateChange<State: Prex.State> {

    /// New value of changes
    public let new: State

    /// Old value of changes
    public let old: State?

    /// Returns specified value when it has changed
    public func changedProperty<Value: Equatable>(for keyPath: KeyPath<State, Value>) -> PropertyChange<Value>? {
        let newValue = new[keyPath: keyPath]
        return newValue == old?[keyPath: keyPath] ? nil : PropertyChange(value: newValue)
    }
}

extension StateChange {

    /// Contains a changed value of specified property
    public struct PropertyChange<T> {
        public let value: T
    }
}
