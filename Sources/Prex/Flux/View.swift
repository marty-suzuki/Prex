//
//  View.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//


/// Represent Flux View component
public protocol View: AnyObject {
    associatedtype State: Prex.State

    /// This method called when state has changed
    ///
    /// - Parameter change: Contains new state and old state
    func reflect(change: ValueChange<State>)
}
