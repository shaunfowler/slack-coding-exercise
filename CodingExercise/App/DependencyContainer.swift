//
//  DependencyContainer.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/26/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation

protocol AutocompleteDependencyContainer {
    func makeAutocompleteViewController() -> AutocompleteViewController
}

/// A dependency container responsible for constructing component dependencies and transitive dependencies.
class DependencyContainer {

    private var networkService: NetworkServiceProtocol = NetworkService()

    private var denyList: DenyList = DynamicDenyList()

    private lazy var userSearchService: UserSearchService = {
        SlackUserSearchService(networkService: networkService)
    }()

    private lazy var userSearchResultDataProvider: UserSearchResultDataProviderInterface = {
        UserSearchResultDataProvider(userSearchService: userSearchService, denyList: denyList)
    }()
}

extension DependencyContainer: AutocompleteDependencyContainer {

    /// Creates the AutocompleteViewController.
    /// - Returns: A view controller.
    func makeAutocompleteViewController() -> AutocompleteViewController {
        let viewModel = AutocompleteViewModel(dataProvider: userSearchResultDataProvider)
        return AutocompleteViewController(viewModel: viewModel)
    }
}
