//
//  TrieTests.swift
//  CodingExerciseTests
//
//  Created by Slack Candidate on 2/23/22.
//  Copyright © 2022 slack. All rights reserved.
//

import Foundation
import XCTest
@testable import CodingExercise

// swiftlint:disable force_try line_length
class TrieTests: XCTestCase {

    let encodedString =
        #"{"children":{"c":{"children":{"a":{"children":{"t":{"children":{},"isWordEnd":true}},"isWordEnd":false}},"isWordEnd":true},"h":{"children":{"e":{"children":{"l":{"children":{"l":{"children":{"o":{"children":{},"isWordEnd":true}},"isWordEnd":false}},"isWordEnd":false}},"isWordEnd":true}},"isWordEnd":false}},"isWordEnd":false}"#

    func testContainsEmptyString() {
        let trie = Trie()
        XCTAssertTrue(trie.contains(""))
    }

    func testInsertAndContains() {

        let trie = Trie()

        trie.insert("hello")

        XCTAssertTrue(trie.contains("h"))
        XCTAssertTrue(trie.contains("hello"))
        XCTAssertFalse(trie.contains("hellot"))

        trie.insert("hellothere")

        XCTAssertTrue(trie.contains("hello"))
        XCTAssertTrue(trie.contains("hellot"))
    }

    func testEncoding() {

        let trie = Trie()

        trie.insert("c")
        trie.insert("he")
        trie.insert("cat")
        trie.insert("hello")

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encodedData = try! encoder.encode(trie)

        XCTAssertEqual(String(data: encodedData, encoding: .utf8),
                       encodedString)
    }

    func testDecoding() {

        let decodedObject = try! JSONDecoder().decode(Trie.self, from: encodedString.data(using: .utf8)!)

        XCTAssertTrue(decodedObject.contains(""))
        XCTAssertTrue(decodedObject.contains("h"))
        XCTAssertTrue(decodedObject.contains("he"))
        XCTAssertTrue(decodedObject.contains("hel"))
        XCTAssertTrue(decodedObject.contains("hell"))
        XCTAssertTrue(decodedObject.contains("hello"))

        XCTAssertTrue(decodedObject.contains("c"))
        XCTAssertTrue(decodedObject.contains("ca"))
        XCTAssertTrue(decodedObject.contains("cat"))
    }
}
