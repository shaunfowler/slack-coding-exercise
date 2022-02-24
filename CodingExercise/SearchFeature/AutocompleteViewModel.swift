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
     */
    func fetchUserNames(_ searchTerm: String?, completionHandler: @escaping ([String]) -> Void)

    /*
     * Updates usernames according to given update string.
     */
    func updateSearchText(text: String?)

    /*
     * Returns a username at the given position.
     */
    func username(at index: Int) -> String

    /*
     * Returns the count of the current usernames array.
     */
    func usernamesCount() -> Int

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
    private var usernames: [String] = []
    private var searchText = CurrentValueSubject<String?, Never>(nil)
    private var subscriptions = Set<AnyCancellable>()

    public weak var delegate: AutocompleteViewModelDelegate?

    init(dataProvider: UserSearchResultDataProviderInterface) {
        self.resultsDataProvider = dataProvider
        monitorSearchText()
    }

    func updateSearchText(text: String?) {
        searchText.send(text)
    }

    func usernamesCount() -> Int {
        return usernames.count
    }

    func username(at index: Int) -> String {
        return usernames[index]
    }

    func fetchUserNames(_ searchTerm: String?, completionHandler: @escaping ([String]) -> Void) {
        guard let term = searchTerm, !term.isEmpty else {
            completionHandler([])
            return
        }

        self.resultsDataProvider.fetchUsers(term) { users in
            completionHandler(users.map { $0.username })
        }
    }

    // MARK: - Private Functions

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

    private func performSearch(text: String) {
        self.fetchUserNames(text) { [weak self] usernames in
            DispatchQueue.main.async {
                self?.usernames = usernames
                self?.delegate?.usersDataUpdated()
            }
        }
    }
}
