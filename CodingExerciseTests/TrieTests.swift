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
        #"{"_c":{"c":{"_c":{"a":{"_c":{"t":{"_c":{},"_we":true}},"_we":false}},"_we":true},"h":{"_c":{"e":{"_c":{"l":{"_c":{"l":{"_c":{"o":{"_c":{},"_we":true}},"_we":false}},"_we":false}},"_we":true}},"_we":false}},"_we":false}"#

    func testContainsEmptyString() {
        let trie = Trie()
        XCTAssertTrue(trie.contains(""))
    }

    func testInsertAndContains() {

        let trie = Trie()

        trie.insert("hello")

        XCTAssertFalse(trie.contains("h"))
        XCTAssertTrue(trie.contains("hello"))
        XCTAssertFalse(trie.contains("hellot"))

        trie.insert("hellothere")

        XCTAssertTrue(trie.contains("hello"))
        XCTAssertFalse(trie.contains("hellot"))
        XCTAssertTrue(trie.contains("hellothere"))
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
        XCTAssertFalse(decodedObject.contains("h"))
        XCTAssertTrue(decodedObject.contains("he"))
        XCTAssertFalse(decodedObject.contains("hel"))
        XCTAssertFalse(decodedObject.contains("hell"))
        XCTAssertTrue(decodedObject.contains("hello"))

        XCTAssertTrue(decodedObject.contains("c"))
        XCTAssertFalse(decodedObject.contains("ca"))
        XCTAssertTrue(decodedObject.contains("cat"))
    }
}
