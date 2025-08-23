public struct Server: Decodable {
    public enum Authentication: String, CaseIterable, CustomStringConvertible, Decodable {
        case clientIPAddress = "client-IP-address"
        case oAuth2 = "OAuth2"
        case passwordCleartext = "password-cleartext"
        case passwordEncrypted = "password-encrypted"
        case smtpAfterPop = "smtp-after-pop"

        // MARK: CustomStringConvertible
        public var description: String {
            switch self {
            case .clientIPAddress, .oAuth2: rawValue
            case .passwordCleartext: "clear-text password"
            case .passwordEncrypted: "encrypted password"
            case .smtpAfterPop: "SMTP after POP"
            }
        }
    }

    public enum ServerType: String, CaseIterable, CustomStringConvertible, Decodable {
        case imap, pop3, smtp

        // MARK: CustomStringConvertible
        public var description: String { rawValue.uppercased() }
    }

    public enum SocketType: String, CaseIterable, CustomStringConvertible, Decodable {
        case startTLS = "STARTTLS", ssl = "SSL"

        // MARK: CustomStringConvertible
        public var description: String { rawValue }
    }

    public let authentication: [Authentication]
    public let hostname: String
    public let port: Int
    public let serverType: ServerType
    public let socketType: SocketType
    public let username: String
}
