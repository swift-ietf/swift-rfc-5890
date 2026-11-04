# swift-rfc-5890

Use this package when you need to convert a domain name between its Unicode form, as people type it, and the ASCII form that DNS uses, as in `münchen.de` and `xn--mnchen-3ya.de`. Start from `IDNA.toASCII(_:)` and `IDNA.toUnicode(_:)`. If you only need the Punycode algorithm for a single string, use swift-rfc-3492. To check that a host name is valid under DNS rules, use swift-domain-standard.

## Laws

- Names are split at dots and each label is converted on its own. A trailing dot is kept, so an absolute name stays absolute. Any other empty label fails, including a name that is only a dot.
- `IDNA.toASCII(_:)` puts every label in NFC first, so canonically equivalent spellings give the same A-label. An ASCII label is lowercased and kept. A label with any non-ASCII character becomes `xn--` followed by its Punycode, with its case left as it is.
- A label longer than 63 bytes fails, measured after conversion in `IDNA.toASCII(_:)` and before decoding in `IDNA.toUnicode(_:)`.
- `IDNA.toUnicode(_:)` lowercases each label before reading it and matches the `xn--` prefix in any case. It decodes an A-label only if converting the result back with `IDNA.toASCII(_:)` gives the same label. So `xn--` alone, an A-label that decodes to pure ASCII and one whose result isn't in NFC all fail.
- Neither direction checks which characters a label may contain beyond this. ASCII labels aren't checked against letter, digit and hyphen rules, Unicode labels aren't checked against the IDNA code point tables or bidi rules, and the whole name has no length limit.
- `IDNA.isALabel(_:)`, `IDNA.isULabel(_:)` and `IDNA.isNRLDHLabel(_:)` look only at the `xn--` prefix, in any case, and at whether the label is all ASCII. They don't decode or validate it.
