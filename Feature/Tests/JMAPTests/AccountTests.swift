import Testing
@testable import JMAP
import Foundation

struct AccountTests {
    @Test func decoderInit() throws {
        let account: Account = try JSONDecoder().decode(Account.self, from: data)
        #expect(account.name == "toddheasley@fastmail.com")
        #expect(account.capabilities.count == 3)
        #expect(account.capabilities[.mail]?.maxSizeMailboxName == 490)
        #expect(account.capabilities[.mail]?.mayCreateTopLevelMailbox == true)
        #expect(account.capabilities[.mail]?.maxSizeAttachmentsPerEmail == 50_000_000)
        #expect(account.capabilities[.mail]?.maxMailboxDepth == nil)
        #expect(account.capabilities[.mail]?.maxMailboxesPerEmail == 1000)
        #expect(account.capabilities[.submission]?.maxDelayedSend == 44_236_800)
        #expect(account.capabilities[.core] != nil)
        #expect(account.capabilities[.calendars] == nil)
        #expect(account.capabilities[.contacts] == nil)
        #expect(account.isReadOnly == false)
        #expect(account.isPersonal == true)
    }
}

// swift-format-ignore
private let data: Data = """
{
    "accountCapabilities": {
        "urn:ietf:params:jmap:submission": {
            "maxDelayedSend": 44236800,
            "submissionExtensions": {}
        },
        "urn:ietf:params:jmap:core": {},
        "urn:ietf:params:jmap:mail": {
            "maxSizeMailboxName": 490,
            "emailQuerySortOptions": [
                "receivedAt",
                "from",
                "to",
                "subject",
                "size",
                "header.x-spam-score"
            ],
            "mayCreateTopLevelMailbox": true,
            "maxSizeAttachmentsPerEmail": 50000000,
            "maxMailboxDepth": null,
            "maxMailboxesPerEmail": 1000
        },
        "https://www.fastmail.com/dev/maskedemail": {}
    },
    "name": "toddheasley@fastmail.com",
    "isReadOnly": false,
    "isPersonal": true
}
""".data(using: .utf8)!
