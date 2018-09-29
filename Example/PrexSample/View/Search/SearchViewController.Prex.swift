//
//  SearchViewController.Prex.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Prex

enum SearchAction: Action {
    case setQuery(String?)
    case setPagination(GitHub.Pagination?)
    case addRepositories([GitHub.Repository])
    case clearRepositories
    case setIsFetching(Bool)
    case setIsEditing(Bool)
    case setError(Error?)
    case setFetchDate(Date)
    case setSelectedRepository(GitHub.Repository?)
}

struct SearchState: State {
    fileprivate(set) var query: String?
    fileprivate(set) var repositories: [GitHub.Repository] = []
    fileprivate(set) var pagination: GitHub.Pagination?
    fileprivate(set) var isEditing = false
    fileprivate(set) var isFetching = false
    fileprivate(set) var error: Error?
    fileprivate(set) var fetchDate: Date?
    fileprivate(set) var selectedRepository: GitHub.Repository?
}

struct SearchMutation: Mutation {
    func mutate(action: SearchAction, state: inout SearchState) {
        switch action {
        case let .addRepositories(repositories):
            state.repositories.append(contentsOf: repositories)

        case .clearRepositories:
            state.repositories.removeAll()

        case let .setPagination(pagination):
            state.pagination = pagination

        case let .setIsFetching(isFetching):
            state.isFetching = isFetching

        case let .setIsEditing(isEditing):
            state.isEditing = isEditing

        case let .setError(error):
            state.error = error

        case let .setQuery(query):
            state.query = query

        case let .setFetchDate(date):
            state.fetchDate = date

        case let .setSelectedRepository(repository):
            state.selectedRepository = repository
        }
    }
}

extension ActionCreator where Action == SearchAction {
    func searchRepositories(query: String, page: Int = 1, session: GitHub.Session) {
        dispatch(action: .setQuery(query))
        dispatch(action: .setIsFetching(true))
        session.searchRepositories(query: query, page: page) { [dispatch] result in
            switch result {
            case let .success(repositories, pagination):
                dispatch(.addRepositories(repositories))
                dispatch(.setPagination(pagination))
            case let .failure(error):
                dispatch(.setError(error))
            }
            dispatch(.setIsFetching(false))
            dispatch(.setFetchDate(Date()))
        }
    }
}

extension Presenter where Action == SearchAction, State == SearchState {
    func fetchRepositories(query: String, session: GitHub.Session = .init()) {
        actionCreator.searchRepositories(query: query, session: session)
    }

    func fetchMoreRepositories(session: GitHub.Session = .init()) {
        guard
            let query = state.query,
            let next = state.pagination?.next,
            state.pagination?.last != nil && !state.isFetching,
            let fetchDate = state.fetchDate,
            fetchDate.timeIntervalSinceNow < -2
        else {
            return
        }

        actionCreator.searchRepositories(query: query, page: next, session: session)
    }

    func selectedIndexPath(_ indexPath: IndexPath) {
        let repository = state.repositories[indexPath.row]
        actionCreator.dispatch(action: .setSelectedRepository(repository))
    }
}
