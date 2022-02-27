//
//  SearchDenyList.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/24/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import UIKit
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
        static let userDefaultsKey = "deny-list"
        static let denyListSeedPath = Bundle.main.path(forResource: "denylist", ofType: "txt")
    }

    private var denyListTerms = Set<String>()
    private var subscriptions = Set<AnyCancellable>()

    // Optimization: Use LRU cache or something that prevents the entire denylist from being loaded in memory in case it gets large
    private var persistedDenyList: [String]? {
        UserDefaults.standard.array(forKey: Constants.userDefaultsKey) as? [String]
    }

    init() {
        // Clear for testing
        // UserDefaults.standard.set(nil, forKey: "deny-list")

        // If a deny list has never been loaded, load the denylist.txt from the bundle.
        // Else restore from UserDefaults.
        if !denyListExists() {
            seedDenyList()
        } else {
            restoreDenyList()
        }

        // Monitor when app goes inactive to save in-memory deny list to UserDefaults.
        // This batch saves all new deny list items since the last app inactive state.
        monitor()
    }

    private func monitor() {
        // Persist to userdefault when app becomes inactive.
        // This is to avoid extra work writing to userdefaults in case the user performs many search queries.
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.set(Array(self.denyListTerms), forKey: Constants.userDefaultsKey)
            }
            .store(in: &subscriptions)
    }

    private func denyListExists() -> Bool {
        if let existing = persistedDenyList, !existing.isEmpty {
            return true
        }
        return false
    }

    private func seedDenyList() {
        let denyList = loadDefaultDenyList()
        denyListTerms = Set(denyList)
        UserDefaults.standard.set(denyList, forKey: Constants.userDefaultsKey)
    }

    private func restoreDenyList() {
        denyListTerms = Set(persistedDenyList ?? [])
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

    func contains(term: String) -> Bool {
        denyListTerms.contains(term.lowercased())
    }

    func insert(term: String) {
        let processedTerm = term.lowercased()
        denyListTerms.insert(processedTerm) // no effect if already in the set
    }
}
