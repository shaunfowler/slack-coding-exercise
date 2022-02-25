//
//  Logger+slack.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import OSLog

extension Logger {

    static var slackApi: Logger {
        Logger.init(subsystem: "slack.CodingExercise", category: "api")
    }

    static var slackDataProvider: Logger {
        Logger.init(subsystem: "slack.CodingExercise", category: "dataprovider")
    }
}
