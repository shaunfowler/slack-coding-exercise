//
//  UserSearchResult.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation

struct UserSearchResult: Codable {
    let username: String
}

struct SearchResponse: Codable {
    let ok: Bool
    let error: String?
    let users: [UserSearchResult]
}
