/// ``JMAPClient`` requests ``Session`` from `Server`.
public struct Server: CustomStringConvertible, Equatable, Sendable {
    public let authorization: Authorization?
    public let host: String
    public let port: Int

    public init(
        authorization: Authorization?,
        host: String,
        port: Int = 443
    ) {
        self.authorization = authorization
        self.host = host
        self.port = port
    }

    // MARK: CustomStringConvertible
    public var description: String { "\(host):\(port)" }
}
