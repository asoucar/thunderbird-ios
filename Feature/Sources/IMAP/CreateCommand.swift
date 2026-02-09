import NIOCore
import NIOIMAP

// Create new mailbox
struct CreateCommand: IMAPCommand {
    let mailboxName: MailboxName
    let parameters: [CreateParameter]

    init(_ mailboxName: MailboxName, parameters: [CreateParameter] = []) {
        self.mailboxName = mailboxName
        self.parameters = parameters
    }

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    var name: String { "create \"\(mailboxName)\"" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .create(mailboxName, parameters))
    }
}
