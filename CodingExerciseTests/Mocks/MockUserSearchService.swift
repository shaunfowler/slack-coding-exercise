//
//  MockUserSearchService.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/23/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
@testable import CodingExercise

class MockUserSearchService: UserSearchable {

    var onFetchUsersCalled: ((String, (Result<[UserSearchResult], SearchError>) -> Void) -> Void)?

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SearchError>) -> Void) {
        onFetchUsersCalled?(searchTerm, completionHandler) ?? completionHandler(.success([]))
    }
}
