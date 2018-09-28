//
//  View.swift
//  Prex
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

public protocol View: AnyObject {
    associatedtype State: Prex.State
    func refrect(value: ChangedValue<State>)
}
