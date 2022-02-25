//
//  LocalizableKey.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

/// An enum representing the available localized strings.
/// Example usage: `LocalizableKey.searchPlaceholder.localized`.
/// The raw value of each enum case represents a key in the "Localizable.strings" resource.
enum LocalizableKey: String {
    case searchPlaceholder = "Search-TextField-Placeholder"
    case searchMessageInitial = "Search-Message-InitialState"
    case searchMessageNoResults = "Search-Message-NoResults"
    case searchMessageError = "Search-Message-Error"
    case searchResultAccLabel = "SearchResult-AccessibilityLabel"
}

extension LocalizableKey {

    /// Returns a localized string for a given `LocalizableKey`.
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
