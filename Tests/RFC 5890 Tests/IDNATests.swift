// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

import Testing

@testable import RFC_5890

/// Tests for IDNA2008 per RFC 5890
struct IDNATests {
    // MARK: - ToASCII Tests

    @Test
    func `ToASCII: German domain`() throws {
        let input = "münchen.de"
        let expected = "xn--mnchen-3ya.de"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Japanese domain`() throws {
        let input = "日本.jp"
        let expected = "xn--wgv71a.jp"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Chinese domain`() throws {
        let input = "中国.cn"
        let expected = "xn--fiqs8s.cn"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Arabic domain`() throws {
        let input = "مصر.eg"
        let expected = "xn--wgbh1c.eg"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test("ToASCII: Greek domain", .disabled("NFC normalization not yet implemented"))
    func testToASCIIGreek() throws {
        // NOTE: Greek accented characters require NFC normalization
        let input = "ελλάδα.gr"
        let expected = "xn--qxam.gr"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Russian domain`() throws {
        let input = "россия.ru"
        let expected = "xn--h1alffa9f.ru"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Korean domain`() throws {
        let input = "한국.kr"
        let expected = "xn--3e0b707e.kr"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Mixed ASCII and non-ASCII`() throws {
        let input = "www.münchen.example.com"
        let expected = "www.xn--mnchen-3ya.example.com"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Already ASCII`() throws {
        let input = "example.com"
        let expected = "example.com"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Uppercase to lowercase`() throws {
        let input = "Example.COM"
        let expected = "example.com"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test("ToASCII: NFC normalization", .disabled("NFC normalization not yet implemented"))
    func testToASCIINormalization() throws {
        // NOTE: This test requires NFC normalization, which we haven't implemented yet
        // Using decomposed form (é as e + combining acute)
        let input = "caf\u{0065}\u{0301}.com"  // café with decomposed é
        let expected = "xn--caf-dma.com"  // Should normalize to NFC

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    // MARK: - ToUnicode Tests

    @Test
    func `ToUnicode: German A-label`() throws {
        let input = "xn--mnchen-3ya.de"
        let expected = "münchen.de"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Japanese A-label`() throws {
        let input = "xn--wgv71a.jp"
        let expected = "日本.jp"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Chinese A-label`() throws {
        let input = "xn--fiqs8s.cn"
        let expected = "中国.cn"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Mixed A-labels and ASCII`() throws {
        let input = "www.xn--mnchen-3ya.example.com"
        let expected = "www.münchen.example.com"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Already Unicode`() throws {
        let input = "example.com"
        let expected = "example.com"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Uppercase A-label prefix`() throws {
        let input = "XN--MNCHEN-3YA.DE"
        let expected = "münchen.de"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    // MARK: - Round-trip Tests

    @Test
    func `Round-trip: German`() throws {
        let original = "münchen.de"

        let ascii = try IDNA.toASCII(original)
        let unicode = try IDNA.toUnicode(ascii)

        #expect(unicode == original)
    }

    @Test
    func `Round-trip: Japanese`() throws {
        let original = "日本語.jp"

        let ascii = try IDNA.toASCII(original)
        let unicode = try IDNA.toUnicode(ascii)

        #expect(unicode == original)
    }

    @Test
    func `Round-trip: Multiple non-ASCII labels`() throws {
        let original = "münchen.café.example.日本"

        let ascii = try IDNA.toASCII(original)
        let unicode = try IDNA.toUnicode(ascii)

        #expect(unicode == original)
    }

    @Test
    func `Round-trip: ASCII domain`() throws {
        let original = "example.com"

        let ascii = try IDNA.toASCII(original)
        let unicode = try IDNA.toUnicode(ascii)

        #expect(unicode == original)
    }

    // MARK: - Label Validation Tests

    @Test
    func `isALabel: Valid A-label`() {
        #expect(IDNA.isALabel("xn--mnchen-3ya"))
        #expect(IDNA.isALabel("xn--wgv71a"))
        #expect(IDNA.isALabel("XN--MNCHEN-3YA"))
    }

    @Test
    func `isALabel: Not an A-label`() {
        #expect(!IDNA.isALabel("example"))
        #expect(!IDNA.isALabel("münchen"))
        #expect(!IDNA.isALabel("xn-test"))
    }

    @Test
    func `isULabel: Valid U-label`() {
        #expect(IDNA.isULabel("münchen"))
        #expect(IDNA.isULabel("日本"))
        #expect(IDNA.isULabel("café"))
    }

    @Test
    func `isULabel: Not a U-label`() {
        #expect(!IDNA.isULabel("example"))
        #expect(!IDNA.isULabel("xn--mnchen-3ya"))
    }

    @Test
    func `isNRLDHLabel: Valid NR-LDH label`() {
        #expect(IDNA.isNRLDHLabel("example"))
        #expect(IDNA.isNRLDHLabel("test-123"))
        #expect(IDNA.isNRLDHLabel("com"))
    }

    @Test
    func `isNRLDHLabel: Not an NR-LDH label`() {
        #expect(!IDNA.isNRLDHLabel("münchen"))
        #expect(!IDNA.isNRLDHLabel("xn--mnchen-3ya"))
    }

    // MARK: - Error Tests

    @Test
    func `ToASCII: Empty label`() {
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toASCII("")
        }
    }

    @Test
    func `ToASCII: Label too long`() {
        // Create a label that will exceed 63 octets after encoding
        // Use a long string of diverse characters to ensure Punycode output exceeds limit
        let longLabel = String(repeating: "日本語", count: 25)  // 75 characters

        #expect(throws: IDNA.Error.labelTooLong) {
            try IDNA.toASCII(longLabel)
        }
    }

    @Test
    func `ToUnicode: Invalid Punycode`() {
        #expect(throws: IDNA.Error.punycodeError) {
            try IDNA.toUnicode("xn--invalid!!!")
        }
    }

    @Test
    func `ToUnicode: Empty label`() {
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toUnicode("")
        }
    }

    // MARK: - Real-world Domains

    @Test
    func `Real-world: Internationalized TLDs`() throws {
        // .भारत (India in Devanagari)
        let india = "example.भारत"
        let indiaASCII = try IDNA.toASCII(india)
        #expect(indiaASCII.hasSuffix(".xn--h2brj9c"))

        // .中国 (China)
        let china = "example.中国"
        let chinaASCII = try IDNA.toASCII(china)
        #expect(chinaASCII.hasSuffix(".xn--fiqs8s"))

        // .рф (Russia)
        let russia = "example.рф"
        let russiaASCII = try IDNA.toASCII(russia)
        #expect(russiaASCII.hasSuffix(".xn--p1ai"))
    }

    @Test
    func `Real-world: Popular internationalized domains`() throws {
        let domains = [
            ("bücher.de", "xn--bcher-kva.de"),
            ("naïve.com", "xn--nave-6pa.com"),
            ("café.fr", "xn--caf-dma.fr"),
            ("zürich.ch", "xn--zrich-kva.ch"),
        ]

        for (unicode, ascii) in domains {
            let result = try IDNA.toASCII(unicode)
            #expect(result == ascii, "Failed for \(unicode)")

            let roundtrip = try IDNA.toUnicode(result)
            #expect(roundtrip == unicode, "Round-trip failed for \(unicode)")
        }
    }
}
