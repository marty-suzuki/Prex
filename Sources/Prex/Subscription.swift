//
//  Subscription.swift
//  Prex
//
//  Created by marty-suzuki on 2018/10/02.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

/// Represents subscription
public struct Subscription<T> {
    
    let token: Token

    init(token: Token) {
        self.token = token
    }
}
