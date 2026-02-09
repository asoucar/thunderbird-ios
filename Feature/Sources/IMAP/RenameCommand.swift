import NIOCore
import NIOIMAP

// Rename an existing mailbox
struct RenameCommand: IMAPCommand {
    let mailboxName: MailboxName
    let targetName: MailboxName

    init(_ mailboxName: MailboxName, to targetName: MailboxName) {
        self.mailboxName = mailboxName
        self.targetName = targetName
    }

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    var name: String { "rename \"\(mailboxName)\" to \"\(targetName)\"" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .rename(from: mailboxName, to: targetName, parameters: [:]))
    }
}
