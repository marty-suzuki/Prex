//
//  SearchPresenterTestCase.swift
//  PrexSampleTests
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Prex
import XCTest
@testable import PrexSample

final class SearchPresenterTestCase: XCTestCase {
    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency(state: .init())
    }

    func testFetchRepositories() {
        let pagination = GitHub.Pagination(next: nil, last: nil, first: nil, prev: nil)
        dependency.session.searchRepositoriesResult = GitHubSearchResult.success(([], pagination))

        var actions: [SearchAction] = []
        let subscription = dependency.dispatcher.register { action in
            actions.append(action)
        }

        let date = Date()
        let query = "test-query"
        let page: Int = 1
        dependency.presenter.fetchRepositories(query: query,
                                               page: page,
                                               session: dependency.session,
                                               makeDate: { date })
        subscription.cancel()

        XCTAssertEqual(actions.count, 6)

        if case let .setQuery(_query) = actions[0] {
            XCTAssertEqual(_query, query)
        } else {
            XCTFail("actions[0] must be .setQuery, but it is \(actions[0])")
        }

        if case let .setIsFetching(isFetching) = actions[1] {
            XCTAssertTrue(isFetching)
        } else {
            XCTFail("actions[1] must be .setIsFetching, but it is \(actions[1])")
        }

//        if case let .addRepositories(_repos) = actions[2] {
//            XCTAssertEqual(_repos, [])
//        } else {
//            XCTFail("actions[2] must be .addRepositories, but it is \(actions[2])")
//        }

        if case let .setPagination(_pagination) = actions[3] {
            XCTAssertEqual(_pagination?.first, pagination.first)
            XCTAssertEqual(_pagination?.last, pagination.last)
            XCTAssertEqual(_pagination?.next, pagination.next)
            XCTAssertEqual(_pagination?.prev, pagination.prev)
        } else {
            XCTFail("actions[3] must be .setPagination, but it is \(actions[3])")
        }

        if case let .setIsFetching(isFetching) = actions[4] {
            XCTAssertFalse(isFetching)
        } else {
            XCTFail("actions[4] must be .setIsFetching, but it is \(actions[4])")
        }

        if case let .setFetchDate(_date) = actions[5] {
            XCTAssertEqual(_date, date)
        } else {
            XCTFail("actions[5] must be .setFetchDate, but is is \(actions[5])")
        }
    }

    func testSetIsFetching() {
        var _change: ValueChange<SearchState>?
        dependency.view.refrectHandler = { _change = $0 }

        dependency.dispatcher.dispatch(.setIsFetching(true))

        guard let change = _change else {
            XCTFail("change is nil")
            return
        }

        let isFetching = change.valueIfChanged(for: \.isFetching)
        XCTAssertNotNil(isFetching)
        XCTAssertTrue(isFetching ?? false)
    }
}

extension SearchPresenterTestCase {
    private struct Dependency {

        let view = MockView()
        let dispatcher: Dispatcher<SearchAction>
        let session = MockGitHubSession()
        let presenter: Presenter<SearchAction, SearchState>

        init(state: SearchState) {
            let flux = Flux(state: state, mutation: SearchMutation())
            self.dispatcher = flux.dispatcher
            self.presenter = Presenter(view: view, flux: flux)
        }
    }

    private final class MockView: View {
        var refrectHandler: ((ValueChange<SearchState>) -> ())?

        func refrect(change: ValueChange<SearchState>) {
            refrectHandler?(change)
        }
    }
}
