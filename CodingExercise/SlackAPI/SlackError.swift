//
//  SlackError.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation

enum SlackError: Error, CustomStringConvertible {
    case invalidData
    case notSuccess(Int)
    case unknown(Error?)

    var description: String {
        // The specifics of the current error types don't matter from a customer POV.
        "Something went wrong while searching 👀. Please try again."
    }
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
