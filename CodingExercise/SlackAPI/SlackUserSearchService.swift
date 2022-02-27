//
//  SlackUserSearchService.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation
import OSLog

// MARK: - Interfaces

enum SlackUserSearchUrl {

    private static let base = "https://slack-users.herokuapp.com/search"

    case query(String)

    var url: URL? {
        switch self {
        case .query(let searchTerm):
            guard var urlComponents = URLComponents(string: SlackUserSearchUrl.base) else { return nil }
            let queryItemQuery = URLQueryItem(name: "query", value: searchTerm)
            urlComponents.queryItems = [queryItemQuery]
            return urlComponents.url
        }
    }
}

protocol UserSearchService {

    /// Fetches users from search API that match the search term.
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SearchError>) -> Void)
}

class SlackUserSearchService: UserSearchService {

    private let networkService: NetworkServiceProtocol

    /// Initializer.
    /// - Parameter networkService: The network service.
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    /// Fetch Slack users based on a given search term.
    /// - Parameters:
    ///   - searchTerm: A string to match users against.
    ///   - completionHandler: The closure invoked when fetching is completed and the user search results are given.
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SearchError>) -> Void) {

        guard let url = SlackUserSearchUrl.query(searchTerm).url else {
            Logger.slackApi.warning("Search term is empty, not performing fetch request.")
            completionHandler(.failure(.invalidUrl))
            return
        }

        networkService.get(url: url) { (result: Result<SearchResponse, NetworkError>) in
            switch result {
            case .success(let response):
                completionHandler(.success(response.users))
            case .failure(_):
                completionHandler(.failure(.requestFailed))

            }
        }
    }
}
