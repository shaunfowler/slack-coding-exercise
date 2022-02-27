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

    var mockApiService: MockUserSearchService!
    var mockDenyList: MockDenyList!

    override func setUp() {
        super.setUp()
        mockApiService = MockUserSearchService()
        mockDenyList = MockDenyList()
    }

    func testDataProviderPassesSearchTextToApi() {

        // Arrange
        let expectation = XCTestExpectation(description: "Search term was passed to API")
        mockApiService.onFetchUsersCalled = { term, completion in
            XCTAssertEqual(term, self.testSearchTerm)
            completion(.success([self.testUser]))
            expectation.fulfill()
        }

        // Act
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService, denyList: mockDenyList)
        dataProvider.fetchUsers(testSearchTerm) { _ in }

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testApiNotCalledIfSearchTermIsInDenyList() {

        // Arrange
        let expectation = XCTestExpectation(description: "Search term was not passed to API")
        expectation.isInverted = true

        mockApiService.onFetchUsersCalled = { _, _ in
            expectation.fulfill() // should not get here!
        }
        mockDenyList.onContainsCalled = { _ in true } // indicates term is in deny list

        // Act
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService, denyList: mockDenyList)
        dataProvider.fetchUsers(testSearchTerm) { _ in }

        // Assert
        wait(for: [expectation], timeout: 1)
    }

    func testDataProviderReceivesErrorFromApi() {

        // Arrange
        let expectation = XCTestExpectation(description: "Data provider received expected error")
        mockApiService.onFetchUsersCalled = { term, completion in
            XCTAssertEqual(term, self.testSearchTerm)
            completion(.failure(.invalidUrl))
        }

        // Act
        let dataProvider = UserSearchResultDataProvider(slackAPI: mockApiService, denyList: mockDenyList)
        dataProvider.fetchUsers(testSearchTerm) { result in
            guard case .failure(.invalidUrl) = result else {
                XCTFail("Unexpected error type")
                return
            }
            expectation.fulfill()
        }

        // Assert
        wait(for: [expectation], timeout: 1)
    }

}
