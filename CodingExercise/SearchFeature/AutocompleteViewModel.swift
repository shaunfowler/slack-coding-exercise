//
//  AutocompleteViewModel.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import Foundation
import Combine

protocol AutocompleteViewModelDelegate: AnyObject {
    func usersDataUpdated()
}

protocol AutocompleteViewModelInterface {
    /*
     * Fetches users from that match a given a search term
     * TODO: Return a model type for the view instead of the API `UserSearchResult` DTO
     */
    func fetchUsers(_ searchTerm: String?, completionHandler: @escaping ([UserSearchResult]) -> Void)

    /*
     * Updates users according to given update string.
     */
    func updateSearchText(text: String?)

    /*
     * Returns a user at the given position.
     */
    func user(at index: Int) -> UserSearchResult

    /*
     * Returns the count of the current users array.
     */
    func userCount() -> Int

    /*
     Delegate that allows to send data updates through callback.
     */
    var delegate: AutocompleteViewModelDelegate? { get set }
}

class AutocompleteViewModel: AutocompleteViewModelInterface {

    private enum Constants {
        static let searchDebounceInSeconds: TimeInterval = 0.33
    }

    private let resultsDataProvider: UserSearchResultDataProviderInterface
    private var users: [UserSearchResult] = []
    private var searchText = CurrentValueSubject<String?, Never>(nil)
    private var subscriptions = Set<AnyCancellable>()

    public weak var delegate: AutocompleteViewModelDelegate?

    init(dataProvider: UserSearchResultDataProviderInterface) {
        self.resultsDataProvider = dataProvider
        monitorSearchText()
        // searchText.send("Al")
    }

    func updateSearchText(text: String?) {
        searchText.send(text)
    }

    func userCount() -> Int {
        return users.count
    }

    func user(at index: Int) -> UserSearchResult {
        return users[index]
    }

    func fetchUsers(_ searchTerm: String?, completionHandler: @escaping ([UserSearchResult]) -> Void) {
        // Empty search term, return no results.
        guard let term = searchTerm, !term.isEmpty else {
            completionHandler([])
            return
        }

        self.resultsDataProvider.fetchUsers(term) { users in
            completionHandler(users)
        }
    }

    // MARK: - Private Functions

    /*
     * Subscribe to changes in search text and debounce to limit load on API while customer is typing.
     */
    private func monitorSearchText() {
        searchText
            .debounce(for: .init(Constants.searchDebounceInSeconds), scheduler: RunLoop.main)
            .print()
            .sink { [weak self] text in
                if let self = self, let text = text {
                    self.performSearch(text: text)
                }
            }
            .store(in: &subscriptions)
    }

    /*
     * Perform the API call and notify delegate on main queue that data has been updated.
     */
    private func performSearch(text: String) {
        self.fetchUsers(text) { [weak self] users in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.users = users
                self.delegate?.usersDataUpdated()
            }
        }
    }
}
