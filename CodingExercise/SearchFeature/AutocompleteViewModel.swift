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
    func onUsersDataUpdated(users: [UserSearchResult], forSearchTerm searchTerm: String?, withError error: SearchError?)
}

protocol AutocompleteViewModelInterface {

    /// The current list of users matching the provided search term.
    var users: [UserSearchResult] { get }

    /// Delegate that allows to send data updates through callback.
    var delegate: AutocompleteViewModelDelegate? { get set }

    /// Updates users according to given update string.
    /// Changes to the user list will be notified via the `onUsersDataUpdated(users:forSearchTerm:withError)` delegate.
    func updateSearchText(text: String?)
}

class AutocompleteViewModel: AutocompleteViewModelInterface {

    // MARK: - Internal Types

    private enum Constants {
        static let searchDebounceInSeconds: TimeInterval = 0.25
    }

    // MARK: - Private Properties

    private let resultsDataProvider: UserSearchResultDataProviderInterface
    private var searchText = CurrentValueSubject<String?, Never>(nil)
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Properties

    private (set) var users = [UserSearchResult]() {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
        }
    }

    public weak var delegate: AutocompleteViewModelDelegate?

    // MARK: - Initialization

    init(dataProvider: UserSearchResultDataProviderInterface) {
        self.resultsDataProvider = dataProvider
        monitorSearchText()
    }

    // MARK: - Public Functions

    func updateSearchText(text: String?) {
        searchText.send(text)
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
                    self.delegate?.onUsersDataUpdated(users: users, forSearchTerm: searchTerm, withError: nil)
                case .failure(let error):
                    self.users = []
                    self.delegate?.onUsersDataUpdated(users: [], forSearchTerm: searchTerm, withError: error)
                }
            }
        }
    }

    /// Subscribe to changes in search text and fire off request to reload users matching search text.
    private func monitorSearchText() {

        // Debounce changes to limit load on API while customer is typing.
        searchText
            .debounce(for: .init(Constants.searchDebounceInSeconds), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }

                // Perform search or clear user list if search term is empty.
                if let text = text, !text.isEmpty {
                    self.fetchUsers(searchTerm: text)
                } else {
                    self.users = []
                    self.delegate?.onUsersDataUpdated(users: [], forSearchTerm: nil, withError: nil)
                }
            }
            .store(in: &subscriptions)
    }
}
