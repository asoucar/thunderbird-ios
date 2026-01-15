@testable import IMAP
import Testing

struct IMAPClientTests {
    @Test(.disabled(if: Server.server.isDisabled)) func connect() async throws {
        let client: IMAPClient = IMAPClient(.server)
        try await client.connect()
        #expect(client.isConnected == true)
        await #expect(throws: IMAPError.alreadyConnected) {
            try await client.connect()
        }
        try? client.disconnect()
    }

    @Test(.disabled(if: Server.server.isDisabled)) func login() async throws {
        let client: IMAPClient = IMAPClient(.server)
        try await client.connect()
        #expect(client.isConnected == true)
        try await client.login()
        try await client.logout()
        try? client.disconnect()
    }

    @Test(.disabled(if: Server.server.isDisabled)) func logout() async throws {
        let client: IMAPClient = IMAPClient(.server)
        try await client.connect()
        #expect(client.isConnected == true)
        try await client.login()
        try await client.logout()
        try? client.disconnect()
    }

    @Test(.disabled(if: Server.server.isDisabled)) func disconnect() async throws {
        let client: IMAPClient = IMAPClient(.server)
        #expect(throws: IMAPError.notConnected) {
            try client.disconnect()
        }
        try await client.connect()
        #expect(client.isConnected == true)
        try client.disconnect()
        #expect(client.isConnected == false)
    }

    @Test func tag() {
        #expect(IMAPClient.tag(0, prefix: "X") == "X001")
        #expect(IMAPClient.tag(1000) == "a999")
        #expect(IMAPClient.tag(999) == "a999")
        let client: IMAPClient = IMAPClient(.server)
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

// Catch when password is being leaked
@Test func isDisabled() {
    #expect(Server.server.isDisabled == true)
}

private extension Server {
    static var server: Self {
        Self(
            .tls,
            hostname: "imap.mail.me.com",
            username: nil,
            password: nil,
            port: 993
        )
    }

    var isDisabled: Bool { (password ?? "").isEmpty }
}
