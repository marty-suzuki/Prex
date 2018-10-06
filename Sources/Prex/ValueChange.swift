//
//  ValueChange.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

/// Containts new and old value
public struct ValueChange<T> {

    /// New value of changes
    public let new: T

    /// Old value of changes
    public let old: T?

    /// Returns specified value when it contains change
    public func valueIfChanged<Value: Equatable>(for keyPath: KeyPath<T, Value>) -> Value? {
        let newValue = new[keyPath: keyPath]
        return newValue == old?[keyPath: keyPath] ? nil : newValue
    }

    /// Returns specified value when it contains change
    ///
    /// - note: This method optimized to Optional type
    public func valueIfChanged<Value: Equatable>(for keyPath: KeyPath<T, Value>) -> Value.Wrapped? where Value: OptionalType {
        let newValue = new[keyPath: keyPath]
        return newValue == old?[keyPath: keyPath] ? nil : newValue.value
    }
}
