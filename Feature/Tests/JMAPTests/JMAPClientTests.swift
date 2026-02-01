@testable import JMAP
import Testing

struct JMAPClientTests {
    @Test(arguments: Server.allCases(disabled: false)) func allMethods(_ server: Server) async throws {
        let client: JMAPClient = try await .session(server)
        #expect(client.session != nil)
        let mailboxes: [Mailbox] = try await client.mailboxes()
        #expect(mailboxes.count > 0)
        #expect(mailboxes.compactMap { $0.role }.contains(.inbox) == true)
        let emails: [Email] = try await client.emails(in: mailboxes.first!)
        for email in emails {
            print(email)
        }
    }
}
