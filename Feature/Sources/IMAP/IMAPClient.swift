import Foundation
import NIO
import NIOIMAP
import NIOSSL
import OSLog

/// Configure `IMAPClient` with a single ``Server``.
public class IMAPClient {
    public let server: Server

    public var capabilities: Set<Capability> = []
    public var namespaces: Set<Namespace> = []
    public var isConnected: Bool { channel != nil && channel!.isActive }

    public func isSupported(_ capability: Capability) -> Bool {
        capabilities.contains(capability)
    }

    /// Bootstrap NIO channel, connect to the configured ``Server``.
    public func connect() async throws {
        logger?.info("Connecting to \(self.server)…")
        resetInactiveChannel()
        guard channel == nil else {
            logger?.error("\(IMAPError.alreadyConnected)")
            throw IMAPError.alreadyConnected
        }
        do {
            self.channel =
                try await ClientBootstrap
                .bootstrap(server: server, logger: logger, group: group)
                .connect(host: server.hostname, port: server.port)
                .get()
            logger?.info("Connected to \(self.server)")
            try await refreshCapabilities()
        } catch {
            logger?.error("\(error)")
            throw IMAPError(error)
        }
    }

    /// Disconnect NIO channel from configured ``Server``; reset to ready for new connection.
    public func disconnect() throws {
        guard let channel else {
            logger?.error("\(IMAPError.notConnected)")
            throw IMAPError.notConnected
        }
        channel.close(promise: nil)
        self.channel = nil
    }

    /// Log in to connected IMAP server using configured ``Server`` credentials.
    public func login() async throws {
        try await login(username: server.username ?? "", password: server.password ?? "")
    }

    /// Log in to connected IMAP ``Server`` using locally specified credentials.
    public func login(username: String, password: String) async throws {
        logger?.info("Logging in \(username)…")
        let capabilities: [Capability] = try await execute(command: LoginCommand(username: username, password: password))
        if !capabilities.isEmpty {
            // IMAP servers can return additional capabilities after login
            logger?.info("Merging capabilities…")
            for capability in capabilities {
                self.capabilities.insert(capability)
            }
            logger?.info("Capabilities: \(self.capabilities)")
        }
    }

    /// Log out from connected IMAP ``Server``; leave active NIO channel connection intact.
    public func logout() async throws {
        logger?.info("Logging out…")
        try await execute(command: VoidCommand(.logout))
    }

    // MARK: Mailbox

    /// List all mailboxes on logged-in IMAP ``Server``.
    public func list(wildcard: Character = .wildcard) async throws -> [Mailbox] {
        logger?.info("Listing mailboxes…")
        return try await execute(command: ListCommand(wildcard: wildcard))
    }

    /// Select a current working mailbox.
    public func select(mailbox: Mailbox) async throws -> Mailbox.Status {
        logger?.info("Selecting mailbox \(mailbox.path.name)…")
        return try await execute(command: SelectCommand(mailbox.path.name))
    }

    public func status(mailbox: Mailbox) async throws -> Mailbox.Status {
        logger?.info("Refreshing mailbox \(mailbox.path.name) status…")
        return try await execute(command: StatusCommand(mailbox.path.name))
    }

    /// Expunge messages flagged as deleted in current working mailbox.
    public func expunge() async throws {
        logger?.info("Expunging selected mailbox…")
        try await execute(command: VoidCommand(.expunge))
    }

    /// Unselect current working mailbox; don't expunge messages flagged as deleted.
    public func unselect() async throws {
        logger?.info("Unselecting mailbox…")
        try await execute(command: VoidCommand(.unselect))
    }

    /// Expunge and unselect current working mailbox.
    public func close() async throws {
        logger?.info("Closing selected mailbox…")
        try await execute(command: VoidCommand(.close))
    }

    // MARK: Message

    public init(
        _ server: Server,
        logger: Logger? = Logger(subsystem: "net.thunderbird", category: "IMAP")
    ) {
        group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.server = server
        self.logger = logger
    }

    // Generate IMAP command tag in traditional format "a001"
    static func tag(_ count: Int, prefix: Character = .prefix) -> String {
        // IMAP uses client-provided unique identifiers, "tags," for matching issued commands to responses
        // Tags can be any ASCII string without spaces
        // Traditionally, tags are prefixed "a," followed by a 3-digit, auto-incremented number: 001...999
        "\(prefix)\(String(format: "%03d", min(max(count, 1), 999)))"
    }

    // Generate next, auto-incrementing IMAP tag using instance counter
    func tag(prefix: Character = .prefix) -> String {
        count = count > 998 ? 1 : count + 1  // Auto-increment tag count; roll back to 1 after 999
        return Self.tag(count, prefix: prefix)
    }

    // Run IMAP command through NIO `IMAPClientHandler` in channel and handle results
    func execute<T: IMAPCommand>(command: T) async throws -> T.Result {
        let logger: Logger? = logger
        logger?.debug("Executing \(command)…")
        if !isConnected {  // Reconnect automagically
            try await connect()
        }
        guard let channel, channel.isActive else {
            logger?.error("\(IMAPError.notConnected)")
            throw IMAPError.notConnected
        }
        let promise: EventLoopPromise<T.Result> = channel.eventLoop.makePromise(of: T.Result.self)
        let tag: String = tag()  // Hold onto specific auto-generated tag
        let handler: T.Handler = T.Handler(tag: tag, promise: promise)
        let seconds: Int64 = max(command.timeout, 1)
        let task: Scheduled = group.next().scheduleTask(in: .seconds(seconds)) {
            let error: IMAPError = .timedOut(seconds: seconds)
            logger?.error("\(error)")
            promise.fail(error)
        }
        defer {
            channel.pipeline.removeHandler(handler, promise: nil)
            task.cancel()
        }
        do {
            try await channel.pipeline.addHandler(handler).get()
            let message: IMAPClientHandler.Message = IMAPClientHandler.OutboundIn.part(.tagged(command.tagged(tag)))
            try await channel.writeAndFlush(message).get()
            let result: T.Result = try await promise.futureResult.get()
            logger?.debug("\(command.description.capitalized(.sentence)) succeeded")
            if let clientBug = handler.clientBug {
                logger?.debug("CLIENTBUG: \(clientBug)")
            }
            return result
        } catch {
            promise.fail(error)
            logger?.error("\(error)")
            throw IMAPError.commandFailed(command.description)
        }
    }

    func refreshNamespaces() async throws {
        logger?.info("Refreshing namespaces…")
        namespaces = Set(try await execute(command: NamespaceCommand()))
        logger?.info("Namespaces: \(self.namespaces)")
    }

    func refreshCapabilities() async throws {
        logger?.info("Refreshing capabilities…")
        capabilities = Set(try await execute(command: CapabilityCommand()))
        logger?.info("Capabilities: \(self.capabilities)")
    }

    func resetInactiveChannel() {
        guard let channel, !channel.isActive else { return }
        self.channel = nil
        logger?.info("Channel reset; ready to connect")
    }

    private var channel: Channel?
    private var count: Int = 0
    private let group: EventLoopGroup
    private let logger: Logger?
}

extension Character {
    public static let delimiter: Self = "."
    public static let wildcard: Self = "*"

    static let prefix: Self = "a"
}

private extension ClientBootstrap {
    static func bootstrap(
        server: Server,
        logger: Logger? = nil,
        group: EventLoopGroup
    ) -> Self {
        Self(group: group).channelInitializer { channel in
            try! channel.pipeline.syncOperations.addHandlers(
                [
                    LoggingHandler(logger),
                    TLSClientHandler(serverHostname: server.hostname),
                    IMAPClientHandler(parserOptions: .max)
                ]
            )
            return channel.eventLoop.makeSucceededFuture(())
        }
    }
}

private extension NIOSSLContext {
    static var ssl: Self { try! Self(configuration: .makeClientConfiguration()) }
}

private func TLSClientHandler(serverHostname: String? = nil) -> NIOSSLClientHandler {
    try! NIOSSLClientHandler(context: .ssl, serverHostname: serverHostname)
}

private extension ResponseParser.Options {
    static var max: Self {
        Self(
            bufferLimit: 1024 * 1024,
            messageAttributeLimit: .max,
            bodySizeLimit: .max,
            literalSizeLimit: IMAPDefaults.literalSizeLimit
        )
    }
}
