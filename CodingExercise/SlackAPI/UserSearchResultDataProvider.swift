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
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping ([UserSearchResult]) -> Void)
}

class UserSearchResultDataProvider: UserSearchResultDataProviderInterface {
    
    private var slackAPI: SlackAPIInterface
    private var denyList: DenyList

    init(slackAPI: SlackAPIInterface, denyList: DenyList) {
        self.slackAPI = slackAPI
        self.denyList = denyList
    }

    func fetchUsers(_ searchTerm: String, completionHandler: @escaping ([UserSearchResult]) -> Void) {

        if denyList.contains(term: searchTerm) {
            NSLog("Search term is in deny list, ignoring search.")
            completionHandler([])
            return
        }

        self.slackAPI.fetchUsers(searchTerm) { [weak self] users in
            if users.isEmpty {
                NSLog("Search term returned no results, adding to deny list.")
                self?.denyList.insert(term: searchTerm)
            }
            completionHandler(users)
        }
    }
}
