//
//  LatoFont.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

/// Constants representing the font file names in our app bundle.
private enum LatoFontName {
    static let regular = "Lato-Regular"
    static let bold = "Lato-Bold"
}

/// Font sizes use the "Default" for dynamic type sizing as defined in:
/// https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/#dynamic-type-sizes
/// Note: Force unwrap `UIFont` as the app should crash if we've incorrectly configured fonts for the project.
private let latoFontStyles: [UIFont.TextStyle: UIFont] = [
    // Titles
    .largeTitle: UIFont(name: LatoFontName.regular, size: 34)!,
    .title1: UIFont(name: LatoFontName.regular, size: 28)!,
    .title2: UIFont(name: LatoFontName.regular, size: 22)!,
    .title3: UIFont(name: LatoFontName.regular, size: 20)!,

    // Headlines
    .headline: UIFont(name: LatoFontName.bold, size: 17)!,
    .subheadline: UIFont(name: LatoFontName.regular, size: 15)!,

    // Body
    .body: UIFont(name: LatoFontName.regular, size: 17)!,
    .callout: UIFont(name: LatoFontName.regular, size: 16)!,

    // Footnote and captions
    .footnote: UIFont(name: LatoFontName.regular, size: 13)!,
    .caption1: UIFont(name: LatoFontName.regular, size: 12)!,
    .caption2: UIFont(name: LatoFontName.regular, size: 11)!
]

extension UIFont {

    /// Get a Lato font for the preset text styles.
    /// - Parameter style: The `UIFont.TextStyle`.
    /// - Returns: A `UIFont` with dynamic type enabled.
    static func lato(_ style: UIFont.TextStyle) -> UIFont {
        guard let font = latoFontStyles[style] else {
            return .preferredFont(forTextStyle: .body)
        }
        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }

    /// Get a Lato font with a custom weight and size. The font adjusts for dynamic type.
    /// - Parameters:
    ///   - weight: The font weight. If the weight is not supported, the default font weight will be used.
    ///   - size: The font size.
    /// - Returns: A `UIFont` with dynamic type enabled.
    static func lato(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: .body)
        switch weight {
        case .bold:
            return metrics.scaledFont(for: UIFont(name: LatoFontName.bold, size: size)!)
        default:
            return UIFont(name: LatoFontName.regular, size: size)!
        }
    }
}
