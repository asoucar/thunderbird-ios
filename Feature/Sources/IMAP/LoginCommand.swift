import NIOCore
import NIOIMAP

struct LoginCommand: IMAPCommand {
    let username: String
    let password: String

    // MARK: IMAPCommand
    typealias Result = [Capability]
    typealias Handler = CapabilityHandler

    static var name: String { "login" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .login(username: username, password: password))
    }
}
