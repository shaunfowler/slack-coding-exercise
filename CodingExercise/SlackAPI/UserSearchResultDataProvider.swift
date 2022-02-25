//
//  UsernameSearchResultDataProvider.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation

// MARK: - Interfaces

protocol UserSearchResultDataProviderInterface {
    /*
     * Fetches users from that match a given a search term
     */
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SlackError>) -> Void)
}

class UserSearchResultDataProvider: UserSearchResultDataProviderInterface {
    
    private var slackAPI: SlackAPIInterface
    private var denyList: DenyList

    init(slackAPI: SlackAPIInterface, denyList: DenyList) {
        self.slackAPI = slackAPI
        self.denyList = denyList
    }

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SlackError>) -> Void) {

        if denyList.contains(term: searchTerm) {
            NSLog("Search term is in deny list, ignoring search.")
            completionHandler(.success([]))
            return
        }

        self.slackAPI.fetchUsers(searchTerm) { [weak self] usersResult in

            switch usersResult {
            case .success(let users):
                if users.isEmpty {
                    NSLog("Search term returned no results, adding to deny list.")
                    self?.denyList.insert(term: searchTerm)
                }
                completionHandler(.success(users))
            case .failure(let error):
                NSLog("Error fetching users: \(error).")
                completionHandler(.failure(error))
            }
        }
    }
}
