@testable import IMAP
import Testing

struct IMAPClientTests {
    @Test(arguments: Server.allCases(disabled: false)) func allCommands(_ server: Server) async throws {
        let client: IMAPClient = IMAPClient(server)
        try await client.connect()
        #expect(client.isConnected == true)
        await #expect(throws: IMAPError.alreadyConnected) {
            try await client.connect()
        }
        try await client.login()
        let mailboxes: [Mailbox] = try await client.list()
        #expect(mailboxes.count > 1)
        if let inbox: Mailbox = mailboxes.filter({ $0.path.name.isInbox }).first {
            let status: Mailbox.Status = try await client.select(mailbox: inbox)
            print(status)
            // status = try await client.status(mailbox: inbox)
        }
        // if let archive: Mailbox = mailboxes.filter({ $0.path.name.description == "Archive" }).first {
        //     let status: Mailbox.Status = try await client.status(mailbox: archive)
        //     print(status)
        // }
        try await client.logout()
        try? client.disconnect()
    }

    @Test func tag() {
        #expect(IMAPClient.tag(0, prefix: "X") == "X001")
        #expect(IMAPClient.tag(1000) == "a999")
        #expect(IMAPClient.tag(999) == "a999")
        let client: IMAPClient = IMAPClient(.aol)
        #expect(client.tag(prefix: "x") == "x001")
        for count in 2...1000 {
            if count > 999 {
                #expect(client.tag() == "a001")  // Test overflow
            } else {
                #expect(client.tag() == "a\(String(format: "%03d", count))")
            }
        }
    }
}
