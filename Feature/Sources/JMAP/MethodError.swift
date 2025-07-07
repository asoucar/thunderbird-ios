import Foundation

/// Errors describing impossible or ineligible``Method`` operation, part of [JMAP core](https://jmap.io/spec-core.html#errors)
public enum MethodError: String, CaseIterable, CustomStringConvertible, Decodable, Error, Identifiable {
    case accountNotFound, accountNotSupportedByMethod, accountReadOnly
    case forbidden
    case invalidArguments, invalidResultReference
    case serverFail, serverPartialFail, serverUnavailable
    case unknownMethod

    // MARK: CustomStringConvertible
    public var description: String { rawValue }

    // MARK: Decodable
    public init(from decoder: any Decoder) throws {
        var container: UnkeyedDecodingContainer = try decoder.unkeyedContainer()
        let _: String = try container.decode(String.self)  // Skip iterable container pointer to next index
        let dictionary: [String: String] = try container.decode([String: String].self)
        guard let error: Self = Self(rawValue: dictionary["type"] ?? "") else {
            throw URLError(.cannotDecodeRawData)
        }
        self = error
    }

    // MARK: Identifiable
    public var id: String { rawValue }
}
