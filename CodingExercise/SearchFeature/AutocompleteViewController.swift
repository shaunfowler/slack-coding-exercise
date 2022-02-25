//
//  AutocompleteViewController.swift
//  CodingExercise
//
//  Copyright © 2021 slack. All rights reserved.
//

import UIKit

class AutocompleteViewController: UIViewController {

    // MARK: - Internal Types

    private enum Constants {
        static let cellIdentifier = "UserSearchCell"
        static let cellRowHeight: CGFloat = 44.0
        static let verticalSpacing: CGFloat = 8.0
        static let horizontalSpacing: CGFloat = 16.0
    }

    // MARK: - Private Properties

    private var viewModel: AutocompleteViewModelInterface

    private lazy var searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = LocalizableKey.searchPlaceholder.localized
        textField.accessibilityLabel = LocalizableKey.searchPlaceholder.localized
        textField.clearButtonMode = .always
        textField.borderStyle = .roundedRect
        textField.font = .lato(.body)
        textField.adjustsFontForContentSizeCategory = true
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.becomeFirstResponder()
        return textField
    }()

    private lazy var searchResultsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.cellRowHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserTableCellView.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.separatorColor = .customSeparator
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    // MARK: - Initialization

    init(viewModel: AutocompleteViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .customBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self

        setupSubviews()
        setupAccessibility()
        subscribeToKeyboardVisibility()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardVisibility()
    }

    private func setupSubviews() {
        view.addSubview(searchTextField)
        view.addSubview(searchResultsTableView)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalSpacing),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalSpacing),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalSpacing),

            searchResultsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Constants.verticalSpacing),
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.verticalSpacing)
        ])
    }

    private func setupAccessibility() {
        searchTextField.isAccessibilityElement = true
        searchTextField.accessibilityTraits = [.searchField]

        searchResultsTableView.isAccessibilityElement = false
        searchResultsTableView.shouldGroupAccessibilityChildren = true
    }

    private func subscribeToKeyboardVisibility() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIApplication.keyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyboardVisibility() {
        NotificationCenter.default.removeObserver(self)
    }

    private func showTableViewMessage(message: String, level: MessageView.Level? = nil) {
        searchResultsTableView.backgroundView = MessageView(message: message, level: level)
    }

    private func hideTableViewMessage() {
        searchResultsTableView.backgroundView = nil
    }

    // MARK: - Selectors

    @objc func textFieldDidChange(textField: UITextField) {
        viewModel.updateSearchText(text: searchTextField.text)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        // Update table view content insets to consider vertical space the keyboard fills.
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height - view.safeAreaInsets.bottom, right: 0)
        searchResultsTableView.contentInset = insets
        searchResultsTableView.scrollIndicatorInsets = insets
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // Remove content insets when keyboard will be hidden.
        searchResultsTableView.contentInset = .zero
        searchResultsTableView.scrollIndicatorInsets = .zero
    }
}

extension AutocompleteViewController: AutocompleteViewModelDelegate {
    func onUsersDataUpdated(users: [UserSearchResult], forSearchTerm searchTerm: String?, withError error: SlackError?) {
        // Display an error if there are no rows to dispaly in the table view.
        switch (users.isEmpty, error) {
        case (false, nil):
            // Clear the message.
            searchResultsTableView.backgroundView = nil

        case (true, nil):
            // Show a placeholder message.
            let message = searchTerm == nil
                ? LocalizableKey.searchMessageInitial.localized
                : LocalizableKey.searchMessageNoResults.localized
            showTableViewMessage(message: message)

        case (_, _):
            // Show a generic error message.
            showTableViewMessage(message: LocalizableKey.searchMessageError.localized, level: .warn)
        }

        // Reload the table view.
        searchResultsTableView.reloadData()
    }
}

extension AutocompleteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AutocompleteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        if let cell = cell as? UserTableCellView {
            let user = viewModel.user(at: indexPath.row)
            cell.nameView.text = user.displayName
            cell.usernameView.text = user.username
            cell.avatarUrl = user.avatarUrl
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userCount()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
