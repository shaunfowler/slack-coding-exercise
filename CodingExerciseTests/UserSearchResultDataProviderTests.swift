//
//  UserSearchResultDataProviderTests.swift
//  CodingExerciseTests
//
//  Copyright © 2021 slack. All rights reserved.
//

import XCTest
@testable import CodingExercise

class UserSearchResultDataProviderTests: XCTestCase {

    let testSearchTerm = "test123"
    let testUser = UserSearchResult(avatarUrl: URL(string: "http://example.com")!, displayName: "Jane", username: "jdoe")

    var mockApiService: MockSlackAPIService!
    var mockDenyList: MockDenyList!

    override func setUp() {
        super.setUp()
        mockApiService = MockSlackAPIService()
        mockDenyList = MockDenyList()
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
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService, denyList: mockDenyList)
        dataProvider.fetchUsers(testSearchTerm) { result in }

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testApiNotCalledIfSearchTermIsInDenyList() {

        // Arrange
        let expectation = XCTestExpectation(description: "Search term was not passed to API")
        expectation.isInverted = true

        mockApiService.onFetchUsersCalled = { term, completion in
            expectation.fulfill() // should not get here!
        }
        mockDenyList.onContainsCalled = { _ in true } // indicates term is in deny list

        // Act
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService, denyList: mockDenyList)
        dataProvider.fetchUsers(testSearchTerm) { result in }

        // Assert
        wait(for: [expectation], timeout: 1)
    }
}