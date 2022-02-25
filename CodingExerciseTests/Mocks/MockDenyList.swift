//
//  MockDenyList.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
@testable import CodingExercise

class MockDenyList: DenyList {

    var onInsertCalled: ((String) -> Void)?
    func insert(term: String) {
        onInsertCalled?(term)
    }

    var onContainsCalled: ((String) -> Bool)?
    func contains(term: String) -> Bool {
        onContainsCalled?(term) ?? false
    }
}
