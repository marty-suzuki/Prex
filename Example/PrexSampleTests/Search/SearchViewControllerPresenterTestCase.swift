//
//  SearchViewControllerPresenterTestCase.swift
//  PrexSampleTests
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex
import XCTest
@testable import PrexSample

final class SearchViewControllerPresenterTestCase: XCTestCase {
    private var dependency: Dependency!

    override func setUp() {
        dependency = Dependency(state: .init())
    }

    func testFetchRepositories() {
        let pagination = GitHub.Pagination(next: nil, last: nil, first: nil, prev: nil)
        dependency.session.searchRepositoriesResult = GitHubSearchResult.success(([], pagination))

        var actions: [SearchAction] = []
        dependency.actionCreator.dispatchHandler = { action in
            actions.append(action)
        }

        dependency.presenter.fetchRepositories(query: "test-query", page: 1, session: dependency.session)
        XCTAssertEqual(actions.count, 6)
    }
}

extension SearchViewControllerPresenterTestCase {
    private struct Dependency {

        let view = MockView()
        let actionCreator = MockActionCreator<SearchAction>()
        let presenter: Presenter<SearchMutation, SearchState, SearchAction>
        let session = MockGitHubSession()

        init(state: SearchState) {
            self.presenter = Presenter(view: view,
                                       state: state,
                                       mutation: .init(),
                                       actionCreator: actionCreator,
                                       dispatcher: .init())
        }
    }

    private final class MockView: View {
        var refrectHandler: ((ValueChange<SearchState>) -> ())?

        func refrect(change: ValueChange<SearchState>) {
            refrectHandler?(change)
        }
    }
}
