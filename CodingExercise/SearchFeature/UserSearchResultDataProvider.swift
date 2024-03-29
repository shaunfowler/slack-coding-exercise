//
//  UserSearchResultDataProvider.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation
import OSLog

/// An interface for fetching users by search term.
protocol UserSearchResultDataProviderInterface {

    /// Fetches users from that match a given a search term
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SearchError>) -> Void)
}

/// A data provider for Slack user search. This data provider handles caching of search results.
class UserSearchResultDataProvider: UserSearchResultDataProviderInterface {

    private var userSearchService: UserSearchable
    private var denyList: DenyList

    /// Creates a new data provider.
    /// - Parameters:
    ///   - userSearchService: The service to fetch remote data from.
    ///   - denyList: A deny list indicating which search terms to ignore.
    init(userSearchService: UserSearchable, denyList: DenyList) {
        self.userSearchService = userSearchService
        self.denyList = denyList
    }

    /// Fetch users asynchronously.
    /// - Parameters:
    ///   - searchTerm: A search term to match against users and user names. This is a prefix search.
    ///   - completionHandler: Closure to be invoked once search results are ready.
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SearchError>) -> Void) {

        if denyList.contains(term: searchTerm) {
            Logger.slackDataProvider.debug("Search term '\(searchTerm, privacy: .private)' is in deny list, ignoring search.")
            completionHandler(.success([]))
            return
        }

        self.userSearchService.fetchUsers(searchTerm) { [weak self] usersResult in
            switch usersResult {
            case .success(let users):
                if users.isEmpty {
                    Logger.slackDataProvider.debug("Search term '\(searchTerm, privacy: .private)', adding to deny list.")
                    self?.denyList.insert(term: searchTerm)
                }
                completionHandler(.success(users))
            case .failure(let error):
                Logger.slackDataProvider.error("Error fetching users: \(error.localizedDescription).")
                completionHandler(.failure(error))
            }
        }
    }
}
