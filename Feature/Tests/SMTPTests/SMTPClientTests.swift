import EmailAddress
import Foundation
import MIME
@testable import SMTP
import Testing

struct SMTPClientTests {
    @Test(arguments: Server.allCases(disabled: false)) func send(server: Server) async throws {
        try await SMTPClient(server).send(.email(EmailAddress(server.username)))
    }
}

private extension Email {
    static func email(_ address: EmailAddress) -> Self {
        Self(
            sender: address,
            recipients: [
                address  // Send to self
            ],
            subject: "Example email subject",
            body: try! Body(parts: [
                Part(data: "For a brief period of time, email body contents were made of plain, ASCII text only :)".data(using: .ascii)!, contentType: .text(.plain, .ascii))
            ]),
            id: UUID(uuidString: "A51D5B17-CA61-4FF1-A4A8-C717289B8F9E")!
        )
    }
}
