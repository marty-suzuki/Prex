//
//  ValueChangeTests.swift
//  PrexTests
//
//  Created by marty-suzuki on 2018/10/08.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import XCTest
@testable import Prex

final class ValueChangeTests: XCTestCase {

    func testOldIsNil() {
        let new = TestState()
        let changes = ValueChange(new: new, old: nil)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNotNil(testCalledCount)
        XCTAssertEqual(testCalledCount, new.testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNotNil(test2CalledCount)
        XCTAssertEqual(test2CalledCount, new.test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNotNil(changed)
        XCTAssertEqual(changed?.value, new.testString)
    }

    func testOldIsNotNilAndSameAsNew() {
        let new = TestState()
        let changes = ValueChange(new: new, old: new)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNil(testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNil(test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNil(changed)
    }

    func testOldIsNotNilAndTestCalledCountChanged() {
        let old = TestState()
        let new = TestState(testCalledCount: old.testCalledCount + 1,
                            test2CalledCount: old.test2CalledCount,
                            testString: old.testString)
        let changes = ValueChange(new: new, old: old)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNotNil(testCalledCount)
        XCTAssertEqual(testCalledCount, new.testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNil(test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNil(changed)
    }

    func testOldIsNotNilAndTestCalledCount2Changed() {
        let old = TestState()
        let new = TestState(testCalledCount: old.testCalledCount,
                            test2CalledCount: old.test2CalledCount + 2,
                            testString: old.testString)
        let changes = ValueChange(new: new, old: old)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNil(testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNotNil(test2CalledCount)
        XCTAssertEqual(test2CalledCount, new.test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNil(changed)
    }

    func testOldIsNotNilAndTestStringChangedToNonOptional() {
        let old = TestState()
        let new = TestState(testCalledCount: old.testCalledCount,
                            test2CalledCount: old.test2CalledCount,
                            testString: "test")
        let changes = ValueChange(new: new, old: old)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNil(testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNil(test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNotNil(changed)
        XCTAssertEqual(changed?.value, new.testString)
    }

    func testOldIsNotNilAndTestStringChangedToOptional() {
        let old = TestState(testCalledCount: 0,
                            test2CalledCount: 0,
                            testString: "test")
        let new = TestState(testCalledCount: old.testCalledCount,
                            test2CalledCount: old.test2CalledCount,
                            testString: nil)
        let changes = ValueChange(new: new, old: old)

        let testCalledCount = changes.valueIfChanged(for: \.testCalledCount)
        XCTAssertNil(testCalledCount)

        let test2CalledCount = changes.valueIfChanged(for: \.test2CalledCount)
        XCTAssertNil(test2CalledCount)

        let changed = changes.valueIfChanged(for: \.testString)
        XCTAssertNotNil(changed)
        XCTAssertEqual(changed?.value, new.testString)
    }
}
