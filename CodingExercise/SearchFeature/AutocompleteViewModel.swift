//
//  AutocompleteViewModel.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation
import Combine

protocol AutocompleteViewModelDelegate: AnyObject {

    /// Indicates the data model has changed. If an error ocurred, the error parameter will not be nil.
    func onUsersDataUpdated(users: [UserSearchResult], withError error: SlackError?)
}

protocol AutocompleteViewModelInterface {

    /// Updates users according to given update string.
    func updateSearchText(text: String?)

    /// Returns a user at the given position.
    func user(at index: Int) -> UserSearchResult

    /// Returns the count of the current users array.
    func userCount() -> Int

    /// Delegate that allows to send data updates through callback.
    var delegate: AutocompleteViewModelDelegate? { get set }
}

class AutocompleteViewModel: AutocompleteViewModelInterface {

    // MARK: - Internal Types

    private enum Constants {
        static let searchDebounceInSeconds: TimeInterval = 0.33
    }

    // MARK: - Private Properties

    private let resultsDataProvider: UserSearchResultDataProviderInterface
    private var searchText = CurrentValueSubject<String?, Never>(nil)
    private var subscriptions = Set<AnyCancellable>()
    private var users: [UserSearchResult] = []

    // MARK: - Public Properties

    public weak var delegate: AutocompleteViewModelDelegate?

    // MARK: - Initialization

    init(dataProvider: UserSearchResultDataProviderInterface) {
        self.resultsDataProvider = dataProvider
        monitorSearchText()
        searchText.send("A")
    }

    // MARK: - Public Functions

    func updateSearchText(text: String?) {
        searchText.send(text)
    }

    func userCount() -> Int {
        return users.count
    }

    func user(at index: Int) -> UserSearchResult {
        return users[index]
    }

    // MARK: - Private Functions

    /// Perform the API call and notify delegate on main queue that data has been updated.
    /// - Parameter searchTerm: The search term.
    private func fetchUsers(searchTerm: String) {
        // Fetch users with given search term.
        resultsDataProvider.fetchUsers(searchTerm) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                // Notify delegate of either user data, or human-redable error message.
                switch result {
                case .success(let users):
                    self.users = users
                    self.delegate?.onUsersDataUpdated(users: users, withError: nil)
                case .failure(let error):
                    self.delegate?.onUsersDataUpdated(users: [], withError: error)
                }
            }
        }
    }

    /// Subscribe to changes in search text and debounce to limit load on API while customer is typing.
    private func monitorSearchText() {
        searchText
            .debounce(for: .init(Constants.searchDebounceInSeconds), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }

                // Perform search or clear user list if search term is empty.
                if let text = text, !text.isEmpty {
                    self.fetchUsers(searchTerm: text)
                } else {
                    self.users = []
                    self.delegate?.onUsersDataUpdated(users: [], withError: nil)
                }
            }
            .store(in: &subscriptions)
    }
}
