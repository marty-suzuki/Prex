//
//  GitHub.Response.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

extension GitHub {
    struct Response<Item: Decodable>: Decodable {
        let totalCount: Int
        let incompleteResults: Bool
        let items: [Item]

        private enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case incompleteResults = "incomplete_results"
            case items
        }
    }
}
