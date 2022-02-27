//
//  UserSearchResult.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation

/// A user search result from the Slack API.
struct UserSearchResult: Codable {
    let avatarUrl: URL
    let displayName: String
    let username: String
}

/// A top-level search response object from the Slack API.
struct SearchResponse: Codable {
    // swiftlint:disable identifier_name
    let ok: Bool
    let error: String?
    let users: [UserSearchResult]
}
