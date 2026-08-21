import RFC_3492

public enum IDNA {}

extension IDNA {

    public static let acePrefix = "xn--"

    public static let maxLabelLength = 63

    public static let maxULabelLength = 252
}

extension IDNA {

    public static func toASCII(_ input: String) throws(Error) -> String {
        let labels = input.split(separator: ".", omittingEmptySubsequences: false)
        var asciiLabels: [String] = []

        for label in labels {
            let asciiLabel = try toLabelASCII(String(label))
            asciiLabels.append(asciiLabel)
        }

        return asciiLabels.joined(separator: ".")
    }

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

extension IDNA {

    private static func toLabelASCII(_ label: String) throws(Error) -> String {
        guard !label.isEmpty else {
            throw Error.emptyLabel
        }

        let normalized = label

        if normalized.allSatisfy({ $0.isASCII }) {

            guard normalized.utf8.count <= maxLabelLength else {
                throw Error.labelTooLong
            }
            return normalized.lowercased()
        }

        let encoded = Punycode.encode(normalized)

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

            let punycodeStart = lowercased.index(lowercased.startIndex, offsetBy: acePrefix.count)
            let punycodePart = String(lowercased[punycodeStart...])

            let decoded: String
            do throws(Punycode.Error) {
                decoded = try Punycode.decode(punycodePart)
            } catch {
                throw Error.punycodeError
            }

            guard decoded.unicodeScalars.count <= maxULabelLength else {
                throw Error.labelTooLong
            }

            return decoded
        }

        return lowercased
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
