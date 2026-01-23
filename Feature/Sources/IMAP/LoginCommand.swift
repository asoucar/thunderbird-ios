import NIOCore
import NIOIMAP

// Log in to IMAP server with user/password combination
struct LoginCommand: IMAPCommand {
    let username: String
    let password: String

    // MARK: IMAPCommand
    typealias Result = [Capability]
    typealias Handler = CapabilityHandler

    var name: String { "login" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .login(username: username, password: password))
    }
}
