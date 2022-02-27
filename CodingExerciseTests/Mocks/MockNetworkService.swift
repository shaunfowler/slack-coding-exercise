//
//  MockNetworkService.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
@testable import CodingExercise

class MockNetworkService: NetworkServiceProtocol {

    var result: Decodable?
    var error: NetworkError?

    func get<T: Decodable>(url: URL, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        if let result = result {
            completionHandler(.success(result as! T))
        }
        if let error = error {
            completionHandler(.failure(error))
        }
    }
}
