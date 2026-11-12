public import RFC_3492

extension IDNA {

    public enum Error: Swift::Error, Equatable {
        case emptyLabel
        case labelTooLong
        case nameTooLong
        case invalidLabel
        case punycodeError(Punycode.Error)
        case invalidACEPrefix
    }
}

extension IDNA.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyLabel: "A domain label is empty"
        case .labelTooLong: "A domain label is longer than 63 octets"
        case .nameTooLong: "The domain name is longer than 253 octets"
        case .invalidLabel: "A domain label is not valid"
        case .punycodeError(let error): "Punycode failed: \(error.description)"
        case .invalidACEPrefix: "A label has the ACE prefix but is not valid Punycode"
        }
    }
}
