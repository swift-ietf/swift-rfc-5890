import Testing

@testable import RFC_5890

extension IDNA {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension IDNA.Test.Unit {

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
}

extension IDNA.Test.`Edge Case` {

    @Test
    func `RFC 5891 §5.3: ToUnicode rejects a fake A-label that encodes pure ASCII`() {
        #expect(throws: IDNA.Error.invalidLabel) {
            try IDNA.toUnicode("xn--abc-.example")
        }
    }

    @Test
    func `RFC 5891 §5.3: ToUnicode rejects an A-label whose U-label is not in NFC`() {
        #expect(throws: IDNA.Error.invalidLabel) {
            try IDNA.toUnicode("xn--cafe-yvc.com")
        }
    }

    @Test
    func `RFC 5891 §5.3: ToUnicode rejects an ACE prefix without a Punycode payload`() {
        #expect(throws: IDNA.Error.invalidACEPrefix) {
            try IDNA.toUnicode("xn--.example")
        }
    }

    @Test
    func `RFC 5890 §2.3.2.1: ToUnicode rejects an A-label longer than 63 octets`() {
        #expect(throws: IDNA.Error.labelTooLong) {
            try IDNA.toUnicode("xn--wgvaaaaaaaaaaaaaaaaaaaaaaaa295fbabbbbbbbbbbbbbbbbbbbbbbb04837bcaccccccccccccccccccccccc")
        }
    }

    @Test
    func `RFC 5891 §5.3: ToUnicode accepts a canonical A-label in mixed case`() throws {
        #expect(try IDNA.toUnicode("Xn--Mnchen-3ya") == "münchen")
    }

    @Test
    func `RFC 5890 §2.3.2.1: ToASCII yields the same A-label for canonically equivalent U-labels`() throws {
        let precomposed = try IDNA.toASCII("\u{03B5}\u{03BB}\u{03BB}\u{03AC}\u{03B4}\u{03B1}")
        let decomposed = try IDNA.toASCII("\u{03B5}\u{03BB}\u{03BB}\u{03B1}\u{0301}\u{03B4}\u{03B1}")
        #expect(precomposed == "xn--hxakic4aa")
        #expect(decomposed == precomposed)
    }

    @Test
    func `RFC 5890 §2.3.2.1: ToUnicode output of an NFC A-label is in NFC`() throws {
        let unicode = try IDNA.toUnicode(IDNA.toASCII("cafe\u{0301}"))
        #expect(Array(unicode.unicodeScalars) == Array("caf\u{00E9}".unicodeScalars))
    }

    @Test
    func `RFC 1034 §3.1: ToASCII preserves the root label of an absolute domain name`() throws {
        #expect(try IDNA.toASCII("münchen.de.") == "xn--mnchen-3ya.de.")
        #expect(try IDNA.toASCII("Example.COM.") == "example.com.")
    }

    @Test
    func `RFC 1034 §3.1: ToUnicode preserves the root label of an absolute domain name`() throws {
        #expect(try IDNA.toUnicode("xn--mnchen-3ya.de.") == "münchen.de.")
        #expect(try IDNA.toUnicode("example.com.") == "example.com.")
    }

    @Test
    func `RFC 1034 §3.1: Only the final label may be the empty root label`() {
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toASCII("example..com")
        }
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toASCII(".")
        }
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toUnicode("example.com..")
        }
    }


    @Test
    func `ToASCII: Greek domain`() throws {
        let input = "ελλάδα.gr"
        let expected = "xn--hxakic4aa.gr"

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

    @Test
    func `RFC 5890 §2.3.2.1: ToASCII normalizes a decomposed U-label to NFC`() throws {
        let input = "caf\u{0065}\u{0301}.com"
        let expected = "xn--caf-dma.com"

        let result = try IDNA.toASCII(input)
        #expect(result == expected)
    }

    @Test
    func `ToUnicode: Uppercase A-label prefix`() throws {
        let input = "XN--MNCHEN-3YA.DE"
        let expected = "münchen.de"

        let result = try IDNA.toUnicode(input)
        #expect(result == expected)
    }

    @Test
    func `ToASCII: Empty label`() {
        #expect(throws: IDNA.Error.emptyLabel) {
            try IDNA.toASCII("")
        }
    }

    @Test
    func `ToASCII: Label too long`() {

        let longLabel = String(repeating: "日本語", count: 25)

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
}

extension IDNA.Test.Integration {

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

    @Test
    func `Real-world: Internationalized TLDs`() throws {

        let india = "example.भारत"
        let indiaASCII = try IDNA.toASCII(india)
        #expect(indiaASCII.hasSuffix(".xn--h2brj9c"))

        let china = "example.中国"
        let chinaASCII = try IDNA.toASCII(china)
        #expect(chinaASCII.hasSuffix(".xn--fiqs8s"))

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
