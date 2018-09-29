//
//  MockActionCreator.swift
//  PrexSampleTests
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex

final class MockActionCreator<Action: Prex.Action>: ActionCreator {
    var dispatchHandler: ((Action) -> ())?

    func dispatch(action: Action) {
        dispatchHandler?(action)
    }
}
