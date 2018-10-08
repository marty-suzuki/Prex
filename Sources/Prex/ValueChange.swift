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
    /// - Returns: If old value has changed non-optional value to nil, returns Changed(value: nil)
    ///            If old value has changed nil to non-optional, returns Changed(value: U)
    ///            If old value has not changed, returns nil
    ///
    /// - note: This method optimized to Optional type
    public func valueIfChanged<Value: Equatable>(for keyPath: KeyPath<T, Value>) -> Changed<Value>? where Value: OptionalType {
        let newValue = new[keyPath: keyPath]
        return newValue == old?[keyPath: keyPath] ? nil : Changed(value: newValue)
    }
}

extension ValueChange {

    /// Changed has an Optional Value
    public struct Changed<U: OptionalType> {
        public let value: U
    }
}
