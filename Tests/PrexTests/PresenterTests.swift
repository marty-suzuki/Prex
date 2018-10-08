//
//  PresenterTests.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/09.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Prex

final class PresenterTests: XCTestCase {

    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency()
    }

    func testDispatch() {
        let action: TestAction = .test

        let expect = expectation(description: "wait action")
        let subscription = dependency.dispatcher.register { [action] in
            XCTAssertEqual(action, $0)
            expect.fulfill()
        }

        dependency.presenter.dispatch(action)
        wait(for: [expect], timeout: 0.1)
        dependency.dispatcher.unregister(subscription)
    }

    func testReflect() {
        let state = dependency.presenter.state

        let expect = expectation(description: "wait refrect")
        let token = dependency.view.refrectCalled.subscribe { [state] changes in
            XCTAssertNil(changes.old)
            XCTAssertEqual(changes.new, state)
            expect.fulfill()
        }

        dependency.presenter.refrect()
        wait(for: [expect], timeout: 0.1)
        dependency.view.refrectCalled.unsubscribe(token)
    }

    func testStateChanges() {
        let state = dependency.presenter.state
        let expectState = TestState(testCalledCount: state.testCalledCount + 1,
                                    test2CalledCount: state.test2CalledCount,
                                    testString: state.testString)

        let expect = expectation(description: "wait refrect")
        let token = dependency.view.refrectCalled.subscribe { [expectState] changes in
            XCTAssertNotNil(changes.old)
            XCTAssertEqual(changes.new, expectState)
            expect.fulfill()
        }

        dependency.presenter.dispatch(.test)
        wait(for: [expect], timeout: 0.1)
        dependency.view.refrectCalled.unsubscribe(token)
    }

    func testDeinit() {
        let dispatcher = dependency.dispatcher
        let view = dependency.view

        let action: TestAction = .test

        let expect = expectation(description: "wait action")
        expect.isInverted = true
        let token = view.refrectCalled.subscribe { changes in
            expect.fulfill()
            XCTFail("view.refrectCalled.subscribe should not call, but it received \(changes)")
        }
        dependency = nil

        dispatcher.dispatch(action)
        wait(for: [expect], timeout: 0.1)
        view.refrectCalled.unsubscribe(token)
    }
}

extension PresenterTests {

    private struct Dependency {

        let store: Store<TestState>
        let dispatcher: Dispatcher<TestAction>
        let view = TestView()
        let presenter: Presenter<TestAction, TestState>

        init() {
            let flux = Flux(state: TestState(), mutation: TestMutation())
            self.store = flux.store
            self.dispatcher = flux.dispatcher
            self.presenter = Presenter(view: view, flux: flux)
        }
    }
}
