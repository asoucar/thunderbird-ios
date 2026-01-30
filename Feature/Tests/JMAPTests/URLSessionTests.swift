import Foundation
@testable import JMAP
import Testing

struct URLSessionTests {
    @Test(.disabled(if: token.isEmpty)) func jmapAPI() async throws {
        let session: Session = try await URLSession.shared.jmapSession("api.fastmail.com", port: 443, authorization: "Bearer \(token)")
        guard let accountID: String = session.accounts.keys.first else {
            throw MethodError.accountNotFound
        }
        let responses: [any MethodResponse] = try await URLSession.shared.jmapAPI(
            [
                Mailbox.GetMethod(accountID)  // Test with ccount-agnostic method
            ],
            url: session.apiURL,
            authorization: "Bearer \(token)"
        )
        try #require(responses.count == 1)
        guard let response: MethodGetResponse = responses.first as? MethodGetResponse else {
            throw MethodError.invalidArguments
        }
        let mailboxes: [Mailbox] = try response.decode([Mailbox].self)
        #expect(mailboxes.count > 0)
        #expect(mailboxes.compactMap { $0.role }.contains(.inbox) == true)
    }

    @Test(.disabled(if: token.isEmpty)) func jmapSession() async throws {
        let session: Session = try await URLSession.shared.jmapSession("api.fastmail.com", port: 443, authorization: "Bearer \(token)")
        #expect(session.username.hasSuffix("@fastmail.com") == true)
    }
}

// Catch when token is being leaked
@Test func emptyToken() {
    #expect(token == "")
}

private let token: String = ""
