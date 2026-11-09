import RFC_3492

public enum IDNA {}

extension IDNA {

    public static let acePrefix = "xn--"

    public static let maxLabelLength = 63

    public static let maxNameLength = 253
}

extension IDNA {

    public static func toASCII(_ input: String) throws(Error) -> String {
        let (labels, isAbsolute) = split(input)
        var asciiLabels: [String] = []

        for label in labels {
            let asciiLabel = try toLabelASCII(String(label))
            asciiLabels.append(asciiLabel)
        }

        let name = asciiLabels.joined(separator: ".")
        guard name.utf8.count <= maxNameLength else {
            throw Error.nameTooLong
        }

        return name + (isAbsolute ? "." : "")
    }

    public static func toUnicode(_ input: String) throws(Error) -> String {
        let (labels, isAbsolute) = split(input)
        var asciiLabels: [String] = []
        var unicodeLabels: [String] = []

        for label in labels {
            let asciiLabel = try toLabelASCII(label.lowercased())
            asciiLabels.append(asciiLabel)
            unicodeLabels.append(try toLabelUnicode(asciiLabel))
        }

        guard asciiLabels.joined(separator: ".").utf8.count <= maxNameLength else {
            throw Error.nameTooLong
        }

        return unicodeLabels.joined(separator: ".") + (isAbsolute ? "." : "")
    }

    private static func split(_ input: String) -> (labels: [Substring], isAbsolute: Bool) {
        var labels = input.split(separator: ".", omittingEmptySubsequences: false)
        guard labels.count > 1, labels.last?.isEmpty == true else {
            return (labels, false)
        }
        labels.removeLast()
        return (labels, true)
    }
}

extension IDNA {

    private static func toLabelASCII(_ label: String) throws(Error) -> String {
        guard !label.isEmpty else {
            throw Error.emptyLabel
        }

        let normalized = String(decoding: label._nfcCodeUnits, as: UTF8.self)

        if normalized.allSatisfy({ $0.isASCII }) {

            guard normalized.utf8.count <= maxLabelLength else {
                throw Error.labelTooLong
            }
            let lowercased = normalized.lowercased()
            if lowercased.hasPrefix(acePrefix) {
                _ = try toLabelUnicode(lowercased)
                return lowercased
            }
            guard isLDH(lowercased) else {
                throw Error.invalidLabel
            }
            return lowercased
        }

        guard isValidULabel(normalized) else {
            throw Error.invalidLabel
        }

        let encoded: String
        do throws(Punycode.Error) {
            encoded = try Punycode.encode(normalized)
        } catch {
            throw Error.punycodeError(error)
        }

        let aLabel = acePrefix + encoded

        guard aLabel.utf8.count <= maxLabelLength else {
            throw Error.labelTooLong
        }

        return aLabel
    }

    private static func toLabelUnicode(_ label: String) throws(Error) -> String {
        guard !label.isEmpty else {
            throw Error.emptyLabel
        }

        let lowercased = label.lowercased()
        if lowercased.hasPrefix(acePrefix) {

            guard lowercased.utf8.count <= maxLabelLength else {
                throw Error.labelTooLong
            }

            let punycodeStart = lowercased.index(lowercased.startIndex, offsetBy: acePrefix.count)
            let punycodePart = String(lowercased[punycodeStart...])

            guard !punycodePart.isEmpty else {
                throw Error.invalidACEPrefix
            }

            let decoded: String
            do throws(Punycode.Error) {
                decoded = try Punycode.decode(punycodePart)
            } catch {
                throw Error.punycodeError(error)
            }

            let reencoded: String
            do throws(Error) {
                reencoded = try toLabelASCII(decoded)
            } catch .labelTooLong {
                throw Error.labelTooLong
            } catch {
                throw Error.invalidLabel
            }

            guard reencoded == lowercased else {
                throw Error.invalidLabel
            }

            return decoded
        }

        guard isLDH(lowercased) else {
            throw Error.invalidLabel
        }

        return lowercased
    }

    private static func isLDH(_ label: String) -> Bool {
        label.utf8.allSatisfy(isLetterDigitHyphen)
            && !label.hasPrefix("-")
            && !label.hasSuffix("-")
    }

    private static func isLetterDigitHyphen(_ byte: UInt8) -> Bool {
        switch byte {
        case UInt8(ascii: "a")...UInt8(ascii: "z"), UInt8(ascii: "A")...UInt8(ascii: "Z"),
            UInt8(ascii: "0")...UInt8(ascii: "9"), UInt8(ascii: "-"):
            return true
        default:
            return false
        }
    }

    private static func isLetterDigitHyphen(_ scalar: Unicode.Scalar) -> Bool {
        scalar.isASCII && isLetterDigitHyphen(UInt8(scalar.value))
    }

    private static func isValidULabel(_ label: String) -> Bool {
        let scalars = Array(label.unicodeScalars)
        guard let first = scalars.first, let last = scalars.last else {
            return false
        }
        guard first != "-", last != "-" else {
            return false
        }
        guard scalars.count < 4 || scalars[2] != "-" || scalars[3] != "-" else {
            return false
        }
        switch first.properties.generalCategory {
        case .nonspacingMark, .spacingMark, .enclosingMark:
            return false
        default:
            break
        }
        return scalars.allSatisfy { !$0.isASCII || isLetterDigitHyphen($0) }
    }
}

extension IDNA {

    public static func isALabel(_ label: String) -> Bool {
        return label.lowercased().hasPrefix(acePrefix)
    }

    public static func isULabel(_ label: String) -> Bool {
        return !label.allSatisfy({ $0.isASCII }) && !isALabel(label)
    }

    public static func isNRLDHLabel(_ label: String) -> Bool {
        return label.allSatisfy({ $0.isASCII }) && !isALabel(label)
    }
}
