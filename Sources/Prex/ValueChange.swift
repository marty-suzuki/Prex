//
//  ValueChange.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public struct ValueChange<T> {
    
    public let new: T
    public let old: T?

    public func valueIfChanged<Value: Equatable>(for keyPath: KeyPath<T, Value>) -> Value? {
        let newValue = new[keyPath: keyPath]
        return newValue == old?[keyPath: keyPath] ? nil : newValue
    }
}
