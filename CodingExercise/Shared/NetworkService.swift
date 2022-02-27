//
//  File.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import OSLog

enum NetworkError: Error {
    case invalidData
    case notSuccess(Int)
    case decodingFailed
    case unknown(Error?)
}

protocol NetworkServiceProtocol {
    func get<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, NetworkError>) -> Void)
}

class NetworkService: NetworkServiceProtocol {

    private let defaultSession = URLSession(configuration: .default)
    private var dataTasks = [URL: URLSessionDataTask]()
    private var queryDataTask: URLSessionDataTask?

    /// A JSON decoder that convers keys from `snake_case` to `camelCase`.
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()


    /// Performs a GET request for the given URL.
    /// - Parameters:
    ///   - url: The URL to request.
    ///   - completionHandler: A completion handlder containing the decoded JSON or an error.
    func get<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {

        // Cancel existing task for this URL.
        dataTasks[url]?.cancel()

        // 🚀
        let task = defaultSession.dataTask(with: url) { [weak self] data, response, error in

            guard let self = self else { return }

            var resultToReturn: T?
            var errorToReturn: NetworkError?

            // Ensure that our data task is cleaned up.
            defer {
                self.dataTasks.removeValue(forKey: url)
                if let resultToReturn = resultToReturn {
                    completionHandler(.success(resultToReturn))
                } else {
                    completionHandler(.failure(errorToReturn ?? .unknown(nil)))
                }
                Logger.slackApi.debug("Current data task count: \(self.dataTasks.count).")
            }

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
                Logger.slackApi.error("Request returned an unexpected status code: \(response.statusCode, privacy: .public).")
                errorToReturn = .notSuccess(response.statusCode)
                return
            }

            do {
                resultToReturn = try self.decoder.decode(T.self, from: data)
            } catch {
                Logger.slackApi.error("Decoding failed with error: \(error.localizedDescription).")
                errorToReturn = .decodingFailed
            }
        }

        // Store data task and start it.
        dataTasks[url] = task
        task.resume()
    }
}
