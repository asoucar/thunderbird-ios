import MIME
import NIOIMAPCore

/// ``IMAPClient`` throws `IMAPError`.
public enum IMAPError: Error, CustomStringConvertible, Equatable {
    case alreadyConnected
    case commandFailed(_ description: String)
    case commandNotSupported(_ description: String)
    case notConnected
    case serverDisconnected
    case timedOut(seconds: Int64)
    case underlying(_ error: Error)  // Wrap NIO errors
    case unexpectedResponse(_ description: String)

    init(_ error: Error) {
        self = error as? Self ?? .underlying(error)
    }

    static func commandFailed(_ command: any IMAPCommand) -> Self {
        .commandFailed(command.description)
    }

    static func commandNotSupported(_ command: any IMAPCommand) -> Self {
        .commandNotSupported(command.description)
    }

    static func unexpectedResponse(_ text: ResponseText) -> Self {
        .unexpectedResponse(text.text)
    }

    // MARK: CustomStringConvertible
    public var description: String {
        switch self {
        case .alreadyConnected: "Already connected"
        case .commandFailed(let description): "\(description.capitalized(.sentence)) failed"
        case .commandNotSupported(let description): "\(description.capitalized(.sentence)) not supported"
        case .notConnected: "Not connected"
        case .serverDisconnected: "Server disconnected"
        case .timedOut(let seconds): "Timed out after \(seconds) \(seconds == 1 ? "second" : "seconds")"
        case .underlying(let error): "Underlying error: \(error.localizedDescription)"
        case .unexpectedResponse(let description): "Unexpected response: \(description)"
        }
    }

    // MARK: Equatable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
}
