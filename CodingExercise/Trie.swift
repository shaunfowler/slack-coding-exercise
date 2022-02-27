//
//  Trie.swift
//  CodingExercise
//
//  Created by Slack Candidate on 2/23/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation

/// A trie data structure.
final class Trie: Codable {

    // MARK: - Private Properties

    /// The `Character` type isn't `Codable`, so use `String`.
    private var children = [String: Trie]()

    /// Indicates if this node is the end of a word.
    private var isWordEnd: Bool = false

    // MARK: - Public Properties

    var isEmpty: Bool {
        children.keys.count == 0
    }

    // MARK: - Public Functions

    /// Insert a word into the trie.
    /// - Parameter word: The string to insert.
    func insert(_ word: String) {
        if word.isEmpty { return }
        insert(word: word, index: 0)
    }

    /// Checks if a word is in the trie.
    /// - Parameter word: A string.
    /// - Returns: True if the word is in the trie. False if the prefix exists but is _not_ a word end.
    func contains(_ word: String) -> Bool {
        if word.isEmpty { return true }
        return contains(word: word, index: 0)
    }

    // MARK: - Private Functions

    private func contains(word: String, index: Int) -> Bool {
        // if reached end, true
        // if not reached end, false
        if index == word.count {
            return isWordEnd
        }

        let characterString = String(word.charAt(index))
        print(characterString, isWordEnd)
        guard let match = children[characterString] else { return false }

        return match.contains(word: word, index: index + 1)
    }

    private func insert(word: String, index: Int) {

        // Base case, end of word reached.
        guard index < word.count else {
            isWordEnd = true
            return
        }

        // Get current character.
        let character = word[word.index(word.startIndex, offsetBy: index)]
        let characterString = String(character)
        // Insert if doesn't exist
        var childNode: Trie
        if let existingChildNode = children[characterString] {
            childNode = existingChildNode
        } else {
            childNode = Trie()
            children[characterString] = childNode
        }

        // Recurse to next character.
        childNode.insert(word: word, index: index + 1)
    }
}

extension StringProtocol {

    func charAt(_ index: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: index)]
    }
}
