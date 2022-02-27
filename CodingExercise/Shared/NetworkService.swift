//
//  File.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import OSLog

/// Represents errors from the network service layer.
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

    // MARK: - Internal Types

    private enum ConfigConstants {
        static let cacheMemorySizeInBytes =  20_000_000 // ~ 20 MB
        static let cacheDiskSizeInBytes   = 100_000_000 // ~ 100 MB
    }

    // MARK: - Private Properties

    /// A configured URLSession using a 20 MB in-memory and 10 MB disk URL cache.
    /// Requests will use cache if available before making a network request.
    private var defaultSession: URLSession {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.timeoutIntervalForRequest = 10
        config.urlCache = URLCache(
            memoryCapacity: ConfigConstants.cacheMemorySizeInBytes,
            diskCapacity: ConfigConstants.cacheDiskSizeInBytes)
        return URLSession(configuration: config)
    }

    /// Dictionary storage for in-flight `URLSessionDataTask`s.
    private var dataTasks = [URL: URLSessionDataTask]()

    /// A JSON decoder that convers keys from `snake_case` to `camelCase`.
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    // MARK: - Public Functions

    /// Performs a GET request for the given URL.
    /// - Parameters:
    ///   - url: The URL to request.
    ///   - completionHandler: A completion handlder containing the decoded JSON or an error.
    func get<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {

        // Cancel existing task for this URL.
        dataTasks[url]?.cancel()

        // Fire off the network request.
        Logger.slackApi.debug("Requesting url: \(url.absoluteString).")

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

            // Handle error cases.
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

            // Decode the response body if the request was successful.
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
