//
//  UIColor+custom.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    // Force-unwrap UIColor as if these are not set, the Assets colors sets are configured incorrectly
    static let customBackground = UIColor(named: "CustomBackground")!
    static let customPrimaryText = UIColor(named: "CustomPrimaryText")!
    static let customSecondaryText = UIColor(named: "CustomSecondaryText")!
    static let imagePlaceholderBackground = UIColor(named: "ImagePlaceholderBackground")!
    static let customSeparator = UIColor(named: "CustomSeparator")!
}
