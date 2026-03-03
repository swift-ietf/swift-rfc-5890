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

import RFC_3492

/// IDNA2008 (Internationalized Domain Names in Applications) per RFC 5890
///
/// IDNA2008 enables the use of internationalized domain names by providing
/// conversion between Unicode (U-labels) and ASCII-compatible encoding (A-labels).
///
/// ## Reference
///
/// RFC 5890: Internationalized Domain Names for Applications (IDNA): Definitions and Document Framework
/// https://datatracker.ietf.org/doc/html/rfc5890
///
/// ## Example
///
/// ```swift
/// // Convert Unicode domain to ASCII (A-label)
/// let ascii = try IDNA.toASCII("münchen.de")
/// // Result: "xn--mnchen-3ya.de"
///
/// // Convert ASCII back to Unicode (U-label)
/// let unicode = try IDNA.toUnicode("xn--mnchen-3ya.de")
/// // Result: "münchen.de"
/// ```
public enum IDNA {
    /// ACE (ASCII Compatible Encoding) prefix for A-labels
    public static let acePrefix = "xn--"

    /// Maximum length of a domain label (63 octets per RFC 1035)
    public static let maxLabelLength = 63

    /// Maximum length of a U-label in code points
    public static let maxULabelLength = 252

    /// Errors that can occur during IDNA processing
    public enum Error: Swift.Error, Equatable {
        case emptyLabel
        case labelTooLong
        case invalidLabel
        case punycodeError
        case invalidACEPrefix
    }
}

extension IDNA {
    /// Converts a Unicode domain name to ASCII (A-label) form
    ///
    /// This operation:
    /// 1. Splits the domain into labels
    /// 2. Normalizes each label to NFC
    /// 3. Encodes non-ASCII labels with Punycode and adds "xn--" prefix
    /// 4. Validates length constraints
    ///
    /// - Parameter input: Unicode domain name (U-label)
    /// - Returns: ASCII-compatible domain name (A-label)
    /// - Throws: `IDNA.Error` if conversion fails
    public static func toASCII(_ input: String) throws(Error) -> String {
        let labels = input.split(separator: ".", omittingEmptySubsequences: false)
        var asciiLabels: [String] = []

        for label in labels {
            let asciiLabel = try toLabelASCII(String(label))
            asciiLabels.append(asciiLabel)
        }

        return asciiLabels.joined(separator: ".")
    }

    /// Converts an ASCII domain name (A-label) to Unicode form (U-label)
    ///
    /// This operation:
    /// 1. Splits the domain into labels
    /// 2. Detects A-labels by "xn--" prefix
    /// 3. Decodes Punycode labels back to Unicode
    /// 4. Validates length constraints
    ///
    /// - Parameter input: ASCII-compatible domain name (A-label)
    /// - Returns: Unicode domain name (U-label)
    /// - Throws: `IDNA.Error` if conversion fails
    public static func toUnicode(_ input: String) throws(Error) -> String {
        let labels = input.split(separator: ".", omittingEmptySubsequences: false)
        var unicodeLabels: [String] = []

        for label in labels {
            let unicodeLabel = try toLabelUnicode(String(label))
            unicodeLabels.append(unicodeLabel)
        }

        return unicodeLabels.joined(separator: ".")
    }
}

// MARK: - Label Processing

extension IDNA {
    /// Converts a single label to ASCII form
    private static func toLabelASCII(_ label: String) throws(Error) -> String {
        guard !label.isEmpty else {
            throw Error.emptyLabel
        }

        // TODO: Implement NFC normalization per IDNA2008 requirements
        // For now, use the label as-is
        let normalized = label

        // Check if label is already ASCII
        if normalized.allSatisfy({ $0.isASCII }) {
            // Validate length
            guard normalized.utf8.count <= maxLabelLength else {
                throw Error.labelTooLong
            }
            return normalized.lowercased()
        }

        // Non-ASCII label - encode with Punycode
        let encoded = Punycode.encode(normalized)

        // Add ACE prefix
        let aLabel = acePrefix + encoded

        // Validate length
        guard aLabel.utf8.count <= maxLabelLength else {
            throw Error.labelTooLong
        }

        return aLabel
    }

    /// Converts a single label from ASCII to Unicode form
    private static func toLabelUnicode(_ label: String) throws(Error) -> String {
        guard !label.isEmpty else {
            throw Error.emptyLabel
        }

        // Check if this is an A-label (starts with ACE prefix)
        let lowercased = label.lowercased()
        if lowercased.hasPrefix(acePrefix) {
            // Extract Punycode part (after "xn--")
            let punycodeStart = lowercased.index(lowercased.startIndex, offsetBy: acePrefix.count)
            let punycodePart = String(lowercased[punycodeStart...])

            // Decode Punycode
            do {
                let decoded = try Punycode.decode(punycodePart)

                // Validate U-label length
                guard decoded.unicodeScalars.count <= maxULabelLength else {
                    throw Error.labelTooLong
                }

                // TODO: Implement NFC normalization per IDNA2008 requirements
                return decoded
            } catch {
                throw Error.punycodeError
            }
        }

        // Not an A-label - return as-is (NR-LDH label)
        return lowercased
    }
}

// MARK: - Validation

extension IDNA {
    /// Checks if a label is an A-label (ACE-encoded)
    public static func isALabel(_ label: String) -> Bool {
        return label.lowercased().hasPrefix(acePrefix)
    }

    /// Checks if a label is a U-label (contains non-ASCII)
    public static func isULabel(_ label: String) -> Bool {
        return !label.allSatisfy({ $0.isASCII }) && !isALabel(label)
    }

    /// Checks if a label is an NR-LDH label (ASCII, no ACE prefix)
    public static func isNRLDHLabel(_ label: String) -> Bool {
        return label.allSatisfy({ $0.isASCII }) && !isALabel(label)
    }
}
