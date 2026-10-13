public import RFC_3492

extension IDNA {

    public enum Error: Swift::Error, Equatable {
        case emptyLabel
        case labelTooLong
        case invalidLabel
        case punycodeError(Punycode.Error)
        case invalidACEPrefix
    }
}
