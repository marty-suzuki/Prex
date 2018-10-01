//
//  SearchViewController.Prex.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
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

extension Presenter where Action == SearchAction, State == SearchState {
    func fetchRepositories(query: String,
                           page: Int = 1,
                           session: GitHubSessionProtocol = GitHub.Session(),
                           makeDate: @escaping () -> Date = { Date() }) {
        dispatch(.setQuery(query))
        dispatch(.setIsFetching(true))
        session.searchRepositories(query: query, page: page) { [weak self] result in
            switch result {
            case let .success(repositories, pagination):
                self?.dispatch(.addRepositories(repositories))
                self?.dispatch(.setPagination(pagination))
            case let .failure(error):
                self?.dispatch(.setError(error))
            }
            self?.dispatch(.setIsFetching(false))
            self?.dispatch(.setFetchDate(makeDate()))
        }
    }

    func fetchMoreRepositories(session: GitHubSessionProtocol = GitHub.Session()) {
        guard
            let query = state.query,
            let next = state.pagination?.next,
            state.pagination?.last != nil && !state.isFetching,
            let fetchDate = state.fetchDate,
            fetchDate.timeIntervalSinceNow < -1
        else {
            return
        }

        fetchRepositories(query: query, page: next, session: session)
    }

    func selectedIndexPath(_ indexPath: IndexPath?) {
        let repository = indexPath.map { state.repositories[$0.row] }
        dispatch(.setSelectedRepository(repository))
    }

    func setIsEditing(_ isEditing: Bool) {
        dispatch(.setIsEditing(isEditing))
    }

    func clearRepositories() {
        dispatch(.clearRepositories)
    }
}
