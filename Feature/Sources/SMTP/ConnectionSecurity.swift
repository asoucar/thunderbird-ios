public enum ConnectionSecurity: String, Codable, CaseIterable, CustomStringConvertible, Identifiable, Sendable {
    case startTLS = "STARTTLS"
    case tls = "SSL/TLS"
    case none

    public static var ssl: Self { .tls }

    // MARK: CustomStringConvertible
    public var description: String { rawValue }

    // MARK: Identifiable
    public var id: String { rawValue }
}
