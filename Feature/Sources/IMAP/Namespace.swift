/// Merged  `NIOIMAPCore.NamespaceResponse` and `NamespaceDescription` model
public struct Namespace: Hashable, Sendable {
    public enum Scope: String, CaseIterable, CustomStringConvertible, Sendable {
        case user, shared, other

        // MARK: CustomStringConvertible
        public var description: String { rawValue }
    }

    public let scope: Scope
    public let delimiter: Character?
    public let prefix: String

    public init(_ scope: Scope, delimiter: Character? = .delimiter, prefix: String = "") {
        self.scope = scope
        self.delimiter = delimiter
        self.prefix = prefix
    }
}
