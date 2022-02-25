//
//  MockSlackAPIService.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/23/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
@testable import CodingExercise

class MockSlackAPIService: SlackAPIInterface {

    var onFetchUsersCalled: ((String, (Result<[UserSearchResult], SlackError>) -> Void) -> Void)?

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SlackError>) -> Void) {
        onFetchUsersCalled?(searchTerm, completionHandler) ?? completionHandler(.success([]))
    }
}
