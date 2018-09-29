//
//  MockGitHubSession.swift
//  PrexSampleTests
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation
@testable import PrexSample

final class MockGitHubSession: GitHubSessionProtocol {
    var searchRepositoriesResult: GitHubSearchResult?
    var searchRepositoriesParams: ((String, Int) -> ())?

    func searchRepositories(query: String, page: Int, completion: @escaping (GitHubSearchResult) -> ()) -> URLSessionTask? {
        searchRepositoriesParams?(query, page)
        if let result = searchRepositoriesResult {
            completion(result)
        }
        return nil
    }
}
