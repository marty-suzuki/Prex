//
//  GitHub.User.swift
//  PrexSample
//
//  Created by marty-suzuki on 2018/09/29.
//  Copyright © 2018 marty-suzuki. All rights reserved.
//

import Foundation

extension GitHub {
    struct User: Codable {
        let login: String
        let id: Int
        let nodeID: String
        let avatarURL: URL
        let gravatarID: String
        let url: URL
        let receivedEventsURL: URL
        let type: String

        private enum CodingKeys: String, CodingKey {
            case login, id
            case nodeID = "node_id"
            case avatarURL = "avatar_url"
            case gravatarID = "gravatar_id"
            case url
            case receivedEventsURL = "received_events_url"
            case type
        }
    }
}
