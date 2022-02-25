//
//  UserTableCellView.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/23/22.
//  Copyright © 2022 slack. All rights reserved.
//

import UIKit
import Kingfisher

class UserTableCellView: UITableViewCell {

    private enum Constants {
        static let cellMinHeight: CGFloat = 44
        static let cellContentInsetVertical: CGFloat = 8
        static let cellContentInsetHorizontal: CGFloat = 16
        static let avatarSize: CGFloat = 28
        static let avatarCornerRadius: CGFloat = 4
        static let avatarToNameSpacing: CGFloat = 12
        static let nameToUsernameSpacing: CGFloat = 8

        static let nameFontSize: CGFloat = 16
        static let nameFontColor: UIColor = .customPrimaryText
        static let usernameFontSize: CGFloat = 16
        static let usernameFontColor: UIColor = .customSecondaryText
    }

    var avatarUrl: URL?  {
        didSet {
            // Use Kingfisher for image loading + caching remote images
            // Credit: https://github.com/onevcat/Kingfisher
            avatarView.kf.setImage(with: avatarUrl)
        }
    }

    private let avatarView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .imagePlaceholderBackground
        imageView.layer.cornerRadius = Constants.avatarCornerRadius
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .lato(weight: .bold, size: Constants.nameFontSize)
        label.textColor = Constants.nameFontColor
        return label
    }()

    let usernameView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .lato(weight: .regular, size: Constants.usernameFontSize)
        label.textColor = Constants.usernameFontColor
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(avatarView)
        addSubview(nameView)
        addSubview(usernameView)

        setupLayoutMargins()
        activateConstraints()
    }

    private func setupLayoutMargins() {
        contentView.layoutMargins = UIEdgeInsets(
            top: Constants.cellContentInsetVertical,
            left: Constants.cellContentInsetHorizontal,
            bottom: Constants.cellContentInsetVertical,
            right: Constants.cellContentInsetHorizontal)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.cellMinHeight),

            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),

            nameView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: Constants.avatarToNameSpacing),

            usernameView.firstBaselineAnchor.constraint(equalTo: nameView.firstBaselineAnchor),
            usernameView.leadingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: Constants.nameToUsernameSpacing),
            usernameView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }
}
