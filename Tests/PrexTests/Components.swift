//
//  Components.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/08.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

@testable import Prex

enum TestAction: Action {
    case test
    case test2
}

struct TestMutation: Mutation {
    let mutateCalled = PubSub<TestAction>()

    func mutate(action: TestAction, state: inout TestState) {
        switch action {
        case .test:
            state.testCalledCount += 1
        case .test2:
            state.test2CalledCount += 1
        }
        mutateCalled.publish(action)
    }
}

struct TestState: State, Equatable {
    fileprivate(set) var testCalledCount: Int = 0
    fileprivate(set) var test2CalledCount: Int = 0
    fileprivate(set) var testString: String? = nil
}

final class TestView: View {
    let refrectCalled = PubSub<ValueChange<TestState>>()

    func refrect(change: ValueChange<TestState>) {
        refrectCalled.publish(change)
    }
}
