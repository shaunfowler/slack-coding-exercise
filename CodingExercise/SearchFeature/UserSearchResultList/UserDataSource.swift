//
//  UserDataSource.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

class UserDataSource: UITableViewDiffableDataSource<UserDataSource.Section, UserSearchResult> {

    enum Section {
        case main
    }

    private enum Constants {
        static let cellIdentifier = "UserSearchCell"
    }

    init(tableView: UITableView) {

        tableView.register(UserTableCellView.self, forCellReuseIdentifier: Constants.cellIdentifier)

        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
            if let cell = cell as? UserTableCellView {
                let user = itemIdentifier
                cell.nameView.text = user.displayName
                cell.usernameView.text = user.username
                cell.avatarUrl = user.avatarUrl
            }
            return cell
        }
    }

    func updateSnapshot(data: [UserSearchResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserSearchResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        apply(snapshot)
    }
}

extension UserSearchResult: Hashable {

    static func == (lhs: UserSearchResult, rhs: UserSearchResult) -> Bool {
        lhs.username == rhs.username
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
}
