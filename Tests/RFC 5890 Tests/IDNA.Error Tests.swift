import RFC_3492
import RFC_5890
import Testing

enum `IDNA.Error Tests` {}

extension `IDNA.Error Tests` {
    @Suite struct `Errors describe themselves` {}
}

extension `IDNA.Error Tests`.`Errors describe themselves` {
    @Test
    func `a Punycode failure names its cause`() {
        #expect(IDNA.Error.punycodeError(.badInput).description == "Punycode failed: Punycode input is not valid")
    }

    @Test
    func `each error has its own description`() {
        let errors: [IDNA.Error] = [.emptyLabel, .labelTooLong, .nameTooLong, .invalidLabel, .invalidACEPrefix]
        #expect(Set(errors.map { $0.description }).count == 5)
    }
}
