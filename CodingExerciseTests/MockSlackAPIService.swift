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

    var onFetchUsersCalled: ((String, ([UserSearchResult]) -> Void) -> Void)?

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping ([UserSearchResult]) -> Void) {
        onFetchUsersCalled?(searchTerm, completionHandler) ?? completionHandler([])
    }
}
