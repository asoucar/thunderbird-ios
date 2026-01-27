import NIOCore
import NIOIMAP

// Unsubscribe from an existing mailbox
struct UnsubscribeCommand: IMAPCommand {
    let mailboxName: MailboxName

    init(_ mailboxName: MailboxName) {
        self.mailboxName = mailboxName
    }

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    var name: String { "unsubscribe \"\(mailboxName)\"" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .unsubscribe(mailboxName))
    }
}
