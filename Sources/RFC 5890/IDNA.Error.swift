extension IDNA {

    public enum Error: Swift.Error, Equatable {
        case emptyLabel
        case labelTooLong
        case invalidLabel
        case punycodeError
        case invalidACEPrefix
    }
}
