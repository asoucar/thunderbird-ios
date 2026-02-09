import Foundation
@testable import IMAP
import MIME
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
            let select: Mailbox.Status = try await client.select(mailbox: inbox)
            #expect(select.messageCount != nil)
            #expect(select.recentCount != nil)
            let status = try await client.status(mailbox: inbox)
            #expect(select.messageCount == status.messageCount)
            #expect(select.recentCount == status.recentCount)
        }
        if let archive: Mailbox = mailboxes.filter({ $0.path.name.description == "Archive" }).first {
            let status: Mailbox.Status = try await client.status(mailbox: archive)
            #expect(status.messageCount != nil)
            #expect(status.recentCount != nil)
            #expect(status.unseenCount != nil)
        }
        let mailbox: Mailbox.Name = Mailbox.Name(UUID().uuidString(2, separator: " "))  // Unique mailbox name w/ space
        let renamed: Mailbox.Name = Mailbox.Name(UUID().uuidString(1))
        try await client.create(mailbox: mailbox)
        try await client.subscribe(mailbox: mailbox)
        try await client.rename(mailbox: mailbox, to: renamed)
        try await client.unsubscribe(mailbox: renamed)  // Renamed mailbox should retain subscription
        try await client.delete(mailbox: renamed)
        try await client.logout()
        try? client.disconnect()
    }
}
