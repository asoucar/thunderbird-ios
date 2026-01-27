import NIOCore
import NIOIMAP

// Subscribe to an existing mailbox
struct SubscribeCommand: IMAPCommand {
    let mailboxName: MailboxName

    init(_ mailboxName: MailboxName) {
        self.mailboxName = mailboxName
    }

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    var name: String { "subscribe \"\(mailboxName)\"" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .subscribe(mailboxName))
    }
}
