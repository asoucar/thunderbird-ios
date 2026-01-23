import Foundation

extension String {

    /// Line is defined as a sequence of octets separated by a [CRLF](https://developer.mozilla.org/en-US/docs/Glossary/CRLF)
    /// Described in [RFC 2045](https://www.rfc-editor.org/rfc/rfc2045#section-2.10)
    public static var crlf: Self { "\r\n" }

    /// ASCII-compatible UUID string separator
    public static var separator: Self { "-" }

    /// ASCII representation, if `String` is ASCII
    public var ascii: Self? {
        guard let data: Data = data(using: .ascii) else {
            return nil
        }
        return Self(data: data, encoding: .ascii)
    }

    /// Capitalization case formats
    public enum Case: CaseIterable {
        case sentence, title
    }

    /// Overload capitalization with alternate case options
    public func capitalized(_ `case`: Case) -> Self {
        switch `case` {
        case .sentence: "\(prefix(1).capitalized)\(dropFirst())"
        case .title: capitalized
        }
    }

    /// Break email header value string into parameter keys and values.
    public var parameters: [Self: Self] {
        var parameters: [Self: Self] = [:]
        for parameter in components(separatedBy: ";") {
            guard let index: String.Index = parameter.firstIndex(of: "=") else {
                continue
            }
            let key: String = "\(parameter.prefix(upTo: index))".lowercased().trimmed()
            let value: String = "\(parameter.trimmed().dropFirst(key.count + 1))".removing(.quotes).trimmed()
            parameters[key] = value
        }
        return parameters
    }

    /// Decode quoted-printable data to given `String.Encoding`.
    public init(quotedPrintable data: Data, encoding: Encoding = .utf8) throws {
        guard
            let string: String = String(data: data, encoding: encoding)?
                .replacingOccurrences(of: "=\r\n", with: "")  // Remove quoted-printable line-limit wrapping
                .replacingOccurrences(of: "=\n", with: "")
        else {
            throw MIMEError.dataNotDecoded(data, encoding: encoding)
        }
        self = try string.decodingQuotedPrintable(to: encoding)
    }

    // Decoding method adapted from https://stackoverflow.com/questions/32184783
    func decodingQuotedPrintable(to encoding: Encoding = .utf8) throws -> Self {
        var string: Self = ""
        var index: Index = startIndex
        while let range = range(of: "=", range: index..<endIndex) {
            string.append(contentsOf: self[index..<range.lowerBound])
            index = range.lowerBound  // Advance index

            // Decode sequence of one or more encoded characters
            var data: Data = Data()
            repeat {
                let code: Substring = self[index...].dropFirst().prefix(2)  // Copy decodable character
                guard code.count > 1, let byte: UInt8 = UInt8(code, radix: 16) else {  // Invalid or incomplete hex code
                    throw MIMEError.dataNotQuotedPrintable
                }
                data.append(byte)
                index = self.index(index, offsetBy: 3)
            } while index != endIndex && self[index] == "="
            guard let decodedString: String = String(data: data, encoding: encoding) else {
                throw MIMEError.dataNotDecoded(data, encoding: encoding)
            }
            string.append(contentsOf: decodedString)
        }
        string.append(contentsOf: self[index..<endIndex])
        return string
    }

    func removing(_ characters: [Character]) -> Self {
        var string: Self = "\(self)"
        for character in characters {
            string = string.replacingOccurrences(of: "\(character)", with: "")
        }
        return string
    }

    func trimmed() -> Self {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public var crlf: String { .crlf }

extension [Character] {
    static var quotes: Self { ["\"", "'"] }
}
