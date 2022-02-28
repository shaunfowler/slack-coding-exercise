//
//  MessageView.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

/// A padded, single-line label view that respects dynamic type.
class MessageView: UIView {

    private enum Constants {
        static let spacing: CGFloat = 16.0
        static let fontSize: CGFloat = 16.0
    }

    private let message: String

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        // Font configuration.
        label.textColor = .customSecondaryText
        label.textAlignment = .center

        // Enable accesibility font scaling up to the container width.
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true

        label.text = message

        return label
    }()

    init(message: String) {
        self.message = message
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        setupFonts()

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spacing),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.spacing)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Adapt to bold font accessibility setting.
        if previousTraitCollection?.legibilityWeight != traitCollection.legibilityWeight {
            setupFonts()
        }
    }

    private func setupFonts() {
        label.font = .lato(weight: UIAccessibility.isBoldTextEnabled ? .bold : .regular, size: Constants.fontSize)
    }
}
