//
//  SlackUserSearchUrlTests.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import XCTest
@testable import CodingExercise

class SlackUserSearchUrlTests: XCTestCase {

    func testQueryUrl() {
        XCTAssertEqual(
            SlackUserSearchUrl.query("hello").url?.absoluteString,
            "https://slack-users.herokuapp.com/search?query=hello"
        )
    }

    func testQueryUrlWithEncoding() {
        XCTAssertEqual(
            SlackUserSearchUrl.query("he llo !").url?.absoluteString,
            "https://slack-users.herokuapp.com/search?query=he%20llo%20!"
        )
    }
}
