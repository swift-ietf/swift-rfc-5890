# swift-rfc-5890

Use this package when you need to convert a domain name between its Unicode form, as people type it, and the ASCII form that DNS uses, as in `münchen.de` and `xn--mnchen-3ya.de`. Start from `IDNA.toASCII(_:)` and `IDNA.toUnicode(_:)`. If you only need the Punycode algorithm for a single string, use swift-rfc-3492. To check that a host name is valid under DNS rules, use swift-domain-standard.

## Laws

- Names are split at dots and each label is converted on its own. A trailing dot is kept, so an absolute name stays absolute. Any other empty label fails, including a name that is only a dot.
- `IDNA.toASCII(_:)` puts every label in NFC first, so canonically equivalent spellings give the same A-label. An ASCII label is lowercased and kept. A label with any non-ASCII character becomes `xn--` followed by its Punycode, with its case left as it is.
- A label longer than 63 bytes fails, measured after conversion in `IDNA.toASCII(_:)` and before decoding in `IDNA.toUnicode(_:)`. A name longer than 253 bytes in its ASCII form, not counting a trailing dot, fails in both directions.
- An A-label, matched by the `xn--` prefix in any case, is accepted in either direction only if decoding it and converting the result back with `IDNA.toASCII(_:)` gives the same label. So `xn--` alone, an A-label that decodes to pure ASCII and one whose result isn't in NFC all fail. `IDNA.toUnicode(_:)` lowercases each label before reading it.
- Any other ASCII label holds only letters, digits and hyphens and doesn't start or end with a hyphen. A Unicode label doesn't start or end with a hyphen, has no hyphens in both its third and fourth positions, doesn't start with a combining mark, and its ASCII characters are letters, digits and hyphens.
- Neither direction checks Unicode labels against the IDNA code point tables of RFC 5892 or the bidi rules of RFC 5893.
- `IDNA.isALabel(_:)`, `IDNA.isULabel(_:)` and `IDNA.isNRLDHLabel(_:)` look only at the `xn--` prefix, in any case, and at whether the label is all ASCII. They don't decode or validate it.
