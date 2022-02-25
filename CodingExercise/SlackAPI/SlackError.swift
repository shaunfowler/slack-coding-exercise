//
//  SlackError.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation

/// Errors produced by the Slack API.
enum SlackError: Error {
    case invalidData
    case notSuccess(Int)
    case unknown(Error?)
}

extension SlackError: Equatable {
    static func == (lhs: SlackError, rhs: SlackError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidData, .invalidData):
            return true
        case (.notSuccess(let lhsCode), .notSuccess(let rhsCode)):
            return lhsCode == rhsCode
        case (.unknown(let lhsError), .unknown(let rhsError)):
            return lhsError.debugDescription == rhsError.debugDescription
        default:
            return false
        }
    }
}
