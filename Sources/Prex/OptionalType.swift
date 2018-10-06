//
//  OptionalType.swift
//  Prex
//
//  Created by marty-suzuki on 2018/10/06.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

/// Represents Optional
public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: Prex.OptionalType {
    public var value: Wrapped? {
        return self
    }
}
