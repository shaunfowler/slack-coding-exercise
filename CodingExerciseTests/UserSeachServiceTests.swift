//
//  UserSeachServiceTests.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import XCTest
@testable import CodingExercise

class UserSeachServiceTests: XCTestCase {

    let sampleResponse = SearchResponse(ok: true, error: nil, users: [
        UserSearchResult(id: 1, avatarUrl: URL(string: "http://example.com")!, displayName: "Jane", username: "jdoe")
    ])

    var userSearchService: UserSearchable!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        userSearchService = UserSearchService(networkService: mockNetworkService)
    }

    func testReceiveSuccess() {

        let expectation = XCTestExpectation(description: "Service received success result")

        mockNetworkService.result = sampleResponse

        userSearchService.fetchUsers("test") { result in
            XCTAssertEqual(try? result.get(), self.sampleResponse.users)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testReceiveError() {

        let expectation = XCTestExpectation(description: "Service received expected error result")

        mockNetworkService.error = .notSuccess(400)

        userSearchService.fetchUsers("test") { result in
            if case .failure(let error) = result {
                XCTAssertEqual(error, .requestFailed)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1)
    }
}
