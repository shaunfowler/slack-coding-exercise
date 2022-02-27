//
//  SearchDenyList.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit
import OSLog
import Combine

protocol DenyList {

    /// Check if a term is contained in the deny list.
    /// - Parameter term: The term to check for.
    /// - Returns: True if the term is in the deny list.
    func insert(term: String)

    /// Insert a term into the denylist.
    /// - Parameter term: The term to insert.
    func contains(term: String) -> Bool
}

/// A deny-list that persists newly added terms.
/// The deny list will keep newly added terms in memory until the app state becomes inactive,
/// and which time the deny list will be persisted.
class DynamicDenyList {

    private enum Constants {
        static let denyListKey = "denylist-trie"
        static let denyListSeedPath = Bundle.main.path(forResource: "denylist", ofType: "txt")
    }

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var denyListTrie = Trie()
    private var subscriptions = Set<AnyCancellable>()

    init() {
        // Uncomment for testing
        // UserDefaults.standard.set(nil, forKey: Constants.denyListKey)

        // Restore cached denylist
        restore()

        // If a deny list has never been loaded from the seed file, load the denylist.txt from the bundle.
        if denyListTrie.isEmpty {
            seedDenyList()
        }

        // Monitor when app goes inactive to save in-memory deny list to UserDefaults.
        // This batch saves all new deny list items since the last app inactive state.
        // The goal is to prevent unecessary CPU cycles on serialization.
        monitor()
    }

    private func monitor() {
        // Persist to userdefault when app becomes inactive.
        // This is to avoid extra work writing to userdefaults in case the user performs many search queries.
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.persist()
            }
            .store(in: &subscriptions)
    }

    private func seedDenyList() {
        let denyList = loadDefaultDenyList()
        denyList.forEach { denyListTrie.insert($0) }
        persist()
    }

    private func persist() {
        if let data = try? encoder.encode(denyListTrie) {
            UserDefaults.standard.set(data, forKey: Constants.denyListKey)
        }
    }

    private func restore() {
        if let data = UserDefaults.standard.data(forKey: Constants.denyListKey),
           let decoded = try? decoder.decode(Trie.self, from: data) {
            denyListTrie = decoded
        }
    }

    private func loadDefaultDenyList() -> [String] {
        guard let url = Constants.denyListSeedPath else {
            return []
        }
        let contents = try? String(contentsOfFile: url)
            .components(separatedBy: .newlines)
            .map { $0.lowercased() }
            .filter { !$0.isEmpty }
        return contents ?? []
    }
}

extension DynamicDenyList: DenyList {

    /// Check if a term is contained in the deny list.
    /// - Parameter term: The term to check for.
    /// - Returns: True if the term is in the deny list.
    func contains(term: String) -> Bool {
        denyListTrie.contains(term.lowercased())
    }

    /// Insert a term into the denylist.
    /// - Parameter term: The term to insert.
    func insert(term: String) {
        let processedTerm = term.lowercased()
        denyListTrie.insert(processedTerm)
    }
}
