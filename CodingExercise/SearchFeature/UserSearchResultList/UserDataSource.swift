//
//  UserDataSource.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit

/// A diffable data source for the user search result table view.
class UserDataSource: UITableViewDiffableDataSource<UserDataSource.Section, UserSearchResult>, UITableViewDelegate {

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

    func update(data: [UserSearchResult]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserSearchResult>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data, toSection: .main)
        apply(snapshot)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserSearchResult: Hashable {

    static func == (lhs: UserSearchResult, rhs: UserSearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
