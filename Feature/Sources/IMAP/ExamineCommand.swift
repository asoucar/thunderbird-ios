import NIOIMAP

// Select current working mailbox in read-only mode
struct ExamineCommand: IMAPCommand {
    let mailboxName: MailboxName

    init(_ mailboxName: MailboxName) {
        self.mailboxName = mailboxName
    }

    // MARK: IMAPCommand
    typealias Result = MailboxStatus
    typealias Handler = ExamineHandler

    var name: String { "examine" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .examine(mailboxName))
    }
}

typealias ExamineHandler = SelectHandler
