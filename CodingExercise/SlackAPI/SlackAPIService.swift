//
//  SlackAPIService.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation

// MARK: - Interfaces

protocol SlackAPIInterface {
    /*
     * Fetches users from search.team API that match the search term
     */
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping ([UserSearchResult]) -> Void)
}

class SlackApi: SlackAPIInterface {

    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?

    private let baseURLString =  "https://slack-users.herokuapp.com/search"

    /**
     * A JSON decoder that convers keys from "snake_case" to "camelCase"/
     */
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /**
     A global shared SlackApi Instance.
     TODO: Remove singleton pattern
     */
    static public let shared: SlackAPIInterface = SlackApi()

    /**
     Fetch Slack users based on a given search term.

     - parameter searchTerm: A string to match users against.
     - parameter completionHandler: The closure invoked when fetching is completed and the user search results are given.
     */
    func fetchUsers(_ searchTerm: String, completionHandler: @escaping ([UserSearchResult]) -> Void) {
        dataTask?.cancel()

        guard var urlComponents = URLComponents(string: baseURLString) else { return }

        let queryItemQuery = URLQueryItem(name: "query", value: searchTerm)
        urlComponents.queryItems = [queryItemQuery]

        guard let url = urlComponents.url else { return }
        dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in

            // These will be the results we return with our completion handler
            var resultsToReturn = [UserSearchResult]()

            // Ensure that our data task is cleaned up and our completion handler is called
            defer {
                self?.dataTask = nil
                completionHandler(resultsToReturn)
            }

            guard let self = self else { return }

            if let error = error {
                NSLog("[API] Request failed with error: \(error.localizedDescription)")
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                NSLog("[API] Request returned an invalid response")
                return
            }

            guard response.statusCode == 200 else {
                NSLog("[API] Request returned an unsupported status code: \(response.statusCode)")
                return
            }

            do {
                let result = try self.decoder.decode(SearchResponse.self, from: data)
                resultsToReturn = result.users
            } catch {
                NSLog("[API] Decoding failed with error: \(error)")
            }
        }

        dataTask?.resume()
    }
}
