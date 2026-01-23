@testable import IMAP
import Testing

struct MailboxNameTests {
    @Test func stringInit() {
        #expect(Mailbox.Name("Inbox") == .inbox)
        #expect(Mailbox.Name("").debugDescription == "")
    }

    // MARK: CustomStringConvertible
    @Test func description() {
        print(Mailbox.Name.inbox.description == "INBOX")
        print(Mailbox.Name("Deleted Items").description == "Deleted Items")
        print(Mailbox.Name("Sent").description == "Sent")
    }
}
