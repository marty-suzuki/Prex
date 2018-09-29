//
//  GitHub.Session.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import Foundation

extension GitHub {

    final class Session {

        private let session: URLSession
        private let baseURL: URL = URL(string: "https://api.github.com")!

        init(session: URLSession = .shared) {
            self.session = session
        }

        private func sendRequest<T: Decodable>(path: String,
                                               method: HttpMethod,
                                               queryItems: [URLQueryItem]?,
                                               completion: @escaping (Result<(T, Pagination)>) -> ()) -> URLSessionTask? {
            let url = baseURL.appendingPathComponent(path)

            guard var componets = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                completion(.failure(Error(message: "failed to generate URLComponents from \(url)")))
                return nil
            }
            componets.queryItems = queryItems?.compactMap { $0 }

            guard var urlRequest = componets.url.map({ URLRequest(url: $0) }) else {
                completion(.failure(Error(message: "failed to generate URLRequest from \(componets)")))
                return nil
            }

            urlRequest.httpMethod = method.rawValue
            urlRequest.allHTTPHeaderFields = ["Accept": "application/json"]

            let task = session.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(Error(message: "no response")))
                    return
                }

                guard let data = data else {
                    completion(.failure(Error(message: "no data")))
                    return
                }

                guard  200..<300 ~= response.statusCode else {
                    completion(.failure(Error(message: "status code is \(response.statusCode)")))
                    return
                }

                let pagination: Pagination
                if let link = response.allHeaderFields["Link"] as? String {
                    pagination = Pagination(link: link)
                } else {
                    pagination = Pagination(next: nil, last: nil, first: nil, prev: nil)
                }

                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success((object, pagination)))
                } catch {
                    completion(.failure(error))
                }
            }

            task.resume()

            return task
        }
    }
}

extension GitHub.Session {
    typealias SearchResult = (GitHub.Session.Result<([GitHub.Repository], GitHub.Pagination)>)

    @discardableResult
    func searchRepositories(query: String, page: Int, completion: @escaping (SearchResult) -> ()) -> URLSessionTask? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "sort", value: "stars")
        ]

        typealias _Result = (GitHub.Session.Result<(GitHub.Response<GitHub.Repository>, GitHub.Pagination)>)
        return sendRequest(path: "/search/repositories", method: .get, queryItems: queryItems) { (result: _Result) in
            switch result {
            case let .success(response, pagination):
                completion(.success((response.items, pagination)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension GitHub.Session {
    enum Result<T> {
        case success(T)
        case failure(Swift.Error)
    }


    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }

    struct Error: Swift.Error {
        let message: String
    }
}
