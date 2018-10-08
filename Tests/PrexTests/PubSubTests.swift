//
//  PubSubTests.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Prex

final class PubSubTests: XCTestCase {

    private var pubsub: PubSub<Int>!

    override func setUp() {
        pubsub = PubSub()
    }

    private func rand() -> Int {
        return Int(arc4random() % 1000)
    }

    func testPublish() {
        let value = rand()

        let expect = expectation(description: "wait topic")
        let token = pubsub.subscribe { [value] in
            XCTAssertEqual(value, $0)
            expect.fulfill()
        }

        pubsub.publish(value)
        wait(for: [expect], timeout: 0.1)
        pubsub.unsubscribe(token)
    }

    func testPublishMultiTimes() {
        let values = [rand(), rand(), rand(), rand(), rand()]

        let expect = expectation(description: "wait topic")
        expect.expectedFulfillmentCount = values.count

        var calledValues: [Int] = []
        let token = pubsub.subscribe {
            calledValues.append($0)
            expect.fulfill()
        }

        values.forEach {
            pubsub.publish($0)
        }
        wait(for: [expect], timeout: 0.1)
        pubsub.unsubscribe(token)

        XCTAssertEqual(values, calledValues)
    }

    func testUnsubscribe() {
        let expect = expectation(description: "wait topic")
        expect.isInverted = true

        let token = pubsub.subscribe { value in
            expect.fulfill()
            XCTFail("pubsub.subscribe should not call, but it received \(value)")
        }
        pubsub.unsubscribe(token)

        pubsub.publish(rand())
        wait(for: [expect], timeout: 0.1)
    }
}
