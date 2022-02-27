//
//  MessageView.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

class MessageView: UIView {

    private enum Constants {
        static let spacing: CGFloat = 16.0
    }

    private let message: String

    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false

        // Font configuration.
        label.font = .lato(.callout)
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
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.spacing),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -Constants.spacing)
        ])
    }
}
