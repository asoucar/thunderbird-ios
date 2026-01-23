import NIOCore
import NIOIMAP

struct LogoutCommand: IMAPCommand {

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    static var name: String { "logout" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .logout)
    }
}
