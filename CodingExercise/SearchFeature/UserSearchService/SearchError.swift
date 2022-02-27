//
//  SlackError.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation

/// Errors produced by the Slack API.
enum SearchError: Error {
    case invalidUrl
    case requestFailed
}
