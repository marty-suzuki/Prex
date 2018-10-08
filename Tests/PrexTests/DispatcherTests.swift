//
//  DispatcherTests.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/08.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Prex

final class DispatcherTests: XCTestCase {

    private var dispatcher: Dispatcher<TestAction>!

    override func setUp() {
        dispatcher = Dispatcher()
    }

    func testDispatch() {
        let action: TestAction = .test

        let expect = expectation(description: "wait action")
        let subscription = dispatcher.register { [action] in
            XCTAssertEqual(action, $0)
            expect.fulfill()
        }

        dispatcher.dispatch(action)
        wait(for: [expect], timeout: 0.1)
        dispatcher.unregister(subscription)
    }

    func testDispatchMultiTimes() {
        let actions: [TestAction] = [.test, .test2, .test, .test, .test2]

        let expect = expectation(description: "wait action")
        expect.expectedFulfillmentCount = actions.count

        var calledActions: [TestAction] = []
        let subscription = dispatcher.register {
            calledActions.append($0)
            expect.fulfill()
        }

        actions.forEach {
            dispatcher.dispatch($0)
        }
        wait(for: [expect], timeout: 0.1)
        dispatcher.unregister(subscription)

        XCTAssertEqual(actions, calledActions)
    }

    func testUnregister() {
        let expect = expectation(description: "wait action")
        expect.isInverted = true

        let subscription = dispatcher.register { action in
            expect.fulfill()
            XCTFail("dispatcher.register should not call, but it received \(action)")
        }
        dispatcher.unregister(subscription)

        dispatcher.dispatch(.test)
        wait(for: [expect], timeout: 0.1)
    }
}
