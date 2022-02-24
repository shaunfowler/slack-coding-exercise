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
        static let textFieldPlaceholder = "Search"
        static let cellIdentifier = "UserSearchCell"
        static let cellRowHeight: CGFloat = 44.0
        static let leftSpacing: CGFloat = 20.0
        static let bottomSpacing: CGFloat = 20.0
        static let rightSpacing: CGFloat = -20.0
    }

    // MARK: - Private Properties

    private var viewModel: AutocompleteViewModelInterface

    private let searchTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.placeholder = Constants.textFieldPlaceholder
        textField.accessibilityLabel = Constants.textFieldPlaceholder
        textField.borderStyle = .roundedRect
        textField.font = .lato(.body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let searchResultsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.cellRowHeight
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UserTableCellView.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.separatorColor = .customSeparator
        return tableView
    }()

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    init(viewModel: AutocompleteViewModelInterface) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .systemBackground
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self

        viewModel.delegate = self
        setupSubviews()
    }

    private func setupSubviews() {
        contentView.addSubview(searchTextField)
        contentView.addSubview(searchResultsTableView)
        view.addSubview(contentView)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: view.frame.height/3),

            searchTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchTextField.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.leftSpacing),
            searchTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Constants.rightSpacing),

            searchResultsTableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: Constants.bottomSpacing),
            searchResultsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            searchResultsTableView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            searchResultsTableView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }

    // MARK: - Selectors

    @objc func textFieldDidChange(textField: UITextField) {
        viewModel.updateSearchText(text: searchTextField.text)
    }
}

extension AutocompleteViewController: UITextFieldDelegate {
    // TODO: Possibly show a message on focus?
}

extension AutocompleteViewController: AutocompleteViewModelDelegate {
    func usersDataUpdated() {
        searchResultsTableView.reloadData()
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
