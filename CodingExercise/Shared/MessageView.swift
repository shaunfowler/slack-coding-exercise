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

    enum Level: String {
        case info = "info.circle"
        case warn = "exclamationmark.triangle"
        case error = "exclamationmark.octagon"
    }

    private enum Constants {
        static let levelIconSize: CGFloat = 48.0
        static let messageSpacing: CGFloat = 16.0
    }

    private let level: Level?
    private let message: String

    private func makeImageView(symbolName: String) -> UIImageView {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: Constants.levelIconSize)
        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfig)

        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .customSecondaryText
        return imageView
    }

    private lazy var messageLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .lato(.callout)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .customSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        if let level = level {
            stackView.addArrangedSubview(makeImageView(symbolName: level.rawValue))
        }
        stackView.addArrangedSubview(messageLabel)
        return stackView
    }()

    init(message: String, level: Level? = nil) {
        self.message = message
        self.level = level
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Constants.messageSpacing),
            stackView.topAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -Constants.messageSpacing),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
        ])
    }
}
