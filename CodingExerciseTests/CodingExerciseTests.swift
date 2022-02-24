//
//  CodingExerciseTests.swift
//  CodingExerciseTests
//
//  Copyright © 2021 slack. All rights reserved.
//

import XCTest
@testable import CodingExercise

class CodingExerciseTests: XCTestCase {

    let testSearchTerm = "test123"
    let testUser = UserSearchResult(avatarUrl: URL(string: "http://example.com")!, displayName: "Jane", username: "jdoe")
    var mockApiService: MockSlackAPIService!

    override func setUp() {
        super.setUp()
        mockApiService = MockSlackAPIService()
    }

    func testDataProviderPassesSearchTextToApi() {
        // Arrange
        let expectation = XCTestExpectation(description: "Search term was passed to API")
        mockApiService.onFetchUsersCalled = { term, completion in
            XCTAssertEqual(term, self.testSearchTerm)
            completion([self.testUser])
            expectation.fulfill()
        }

        // Act
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService)
        dataProvider.fetchUsers(testSearchTerm) { result in }

        // Assert
        wait(for: [expectation], timeout: 1)
    }
}
