//
//  SlackAPIService.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation
import OSLog

// MARK: - Interfaces

protocol SlackAPIInterface {
    /*
     * Fetches users from search.team API that match the search term
     */
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SlackError>) -> Void)
}

class SlackApi: SlackAPIInterface {

    private let defaultSession = URLSession(configuration: .default)
    private var dataTask: URLSessionDataTask?

    private let baseURLString =  "https://slack-users.herokuapp.com/search"

    /// A JSON decoder that convers keys from `snake_case` to `camelCase`.
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// Fetch Slack users based on a given search term.
    /// - Parameters:
    ///   - searchTerm: A string to match users against.
    ///   - completionHandler: The closure invoked when fetching is completed and the user search results are given.
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping (Result<[UserSearchResult], SlackError>) -> Void) {

        dataTask?.cancel()

        guard var urlComponents = URLComponents(string: baseURLString) else { return }

        let queryItemQuery = URLQueryItem(name: "query", value: searchTerm)
        urlComponents.queryItems = [queryItemQuery]

        // TODO: Generic request interface

        guard let url = urlComponents.url else { return }
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in

            // These will be the results we return with our completion handler
            var resultsToReturn = [UserSearchResult]()
            var errorToReturn: SlackError?

            // Ensure that our data task is cleaned up and our completion handler is called
            defer {
                self?.dataTask = nil
                if let errorToReturn = errorToReturn {
                    completionHandler(.failure(errorToReturn))
                } else {
                    completionHandler(.success(resultsToReturn))
                }
            }

            guard let self = self else { return }

            // if searchTerm == "!!!" { errorToReturn = .unknown(nil) } // test errors

            if let error = error {
                Logger.slackApi.error("Request failed with error: \(error.localizedDescription).")
                errorToReturn = .unknown(error)
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                Logger.slackApi.error("Request returned an invalid response.")
                errorToReturn = .invalidData
                return
            }

            guard response.statusCode == 200 else {
                Logger.slackApi.error("Request returned an unsupported status code: \(response.statusCode).")
                errorToReturn = .notSuccess(response.statusCode)
                return
            }

            do {
                let result = try self.decoder.decode(SearchResponse.self, from: data)
                resultsToReturn = result.users
            } catch {
                Logger.slackApi.error("Decoding failed with error: \(error.localizedDescription).")
            }
        }

        dataTask?.resume()
    }
}
