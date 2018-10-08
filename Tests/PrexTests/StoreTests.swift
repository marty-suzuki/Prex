//
//  StoreTests.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/08.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Prex

final class StoreTests: XCTestCase {

    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency()
    }

    func testStoreChanges() {
        XCTAssertEqual(dependency.store.state.testCalledCount, 0)
        dependency.dispatcher.dispatch(.test)
        XCTAssertEqual(dependency.store.state.testCalledCount, 1)
    }

    func testMultiStoreChanges() {
        let count: Int = 10
        XCTAssertEqual(dependency.store.state.testCalledCount, 0)
        (0..<count).forEach { _ in
            dependency.dispatcher.dispatch(.test)
        }
        XCTAssertEqual(dependency.store.state.testCalledCount, count)
    }

    func testAddListener() {
        XCTAssertEqual(dependency.store.state.testCalledCount, 0)

        let expect = expectation(description: "wait changes")
        let subscription = dependency.store.addListener(callback: { changes in
            let count = changes.valueIfChanged(for: \.testCalledCount)
            XCTAssertNotNil(count)
            XCTAssertEqual(count, 1)
            expect.fulfill()
        })

        dependency.dispatcher.dispatch(.test)
        wait(for: [expect], timeout: 0.1)
        dependency.store.removeListener(with: subscription)
    }

    func testRemoveListener() {
        XCTAssertEqual(dependency.store.state.testCalledCount, 0)

        let expect = expectation(description: "wait changes")
        expect.isInverted = true

        let subscription = dependency.store.addListener(callback: { changes in
            expect.fulfill()
            XCTFail("store.addListener should not call, but it received \(changes)")
        })
        dependency.store.removeListener(with: subscription)

        dependency.dispatcher.dispatch(.test)
        wait(for: [expect], timeout: 0.1)
    }

    func testMutate() {
        let action: TestAction = .test

        let expect = expectation(description: "wait action")
        let token = dependency.mutation.mutateCalled.subscribe { [action] in
            XCTAssertEqual(action, $0)
            expect.fulfill()
        }

        dependency.dispatcher.dispatch(action)
        wait(for: [expect], timeout: 0.1)
        dependency.mutation.mutateCalled.unsubscribe(token)
    }

    func testDeinit() {
        let dispatcher = dependency.dispatcher
        let mutation = dependency.mutation
        let action: TestAction = .test

        let expect = expectation(description: "wait action")
        expect.isInverted = true
        let token = mutation.mutateCalled.subscribe { action in
            expect.fulfill()
             XCTFail("mutation.mutateCalled.subscribe should not call, but it received \(action)")
        }
        dependency = nil

        dispatcher.dispatch(action)
        wait(for: [expect], timeout: 0.1)
        mutation.mutateCalled.unsubscribe(token)
    }
}

extension StoreTests {

    private struct Dependency {

        let mutation = TestMutation()
        let store: Store<TestState>
        let dispatcher: Dispatcher<TestAction>

        init() {
            let flux = Flux(state: TestState(), mutation: mutation)
            dispatcher = flux.dispatcher
            store = flux.store
        }
    }
}
