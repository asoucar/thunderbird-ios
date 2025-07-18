import Foundation
@testable import JMAP
import Testing

struct SessionTests {
    @Test func decoderInit() throws {
        let session: Session = try JSONDecoder().decode(Session.self, from: data)
        #expect(session.username == "toddheasley@fastmail.com")
        #expect(session.accounts.count == 1)
        #expect(session.accounts["u7a51e404"]?.name == "toddheasley@fastmail.com")
        #expect(session.primaryAccounts.count == 3)
        #expect(session.primaryAccounts[.mail] == "u7a51e404")
        #expect(session.capabilities[.core]?.maxConcurrentRequests == 10)
        #expect(session.downloadURLTemplate == "https://www.fastmailusercontent.com/jmap/download/{accountId}/{blobId}/{name}?type={type}")
        #expect(session.uploadURLTemplate == "https://api.fastmail.com/jmap/upload/{accountId}/")
        #expect(session.eventSourceURL.absoluteString == "https://api.fastmail.com/jmap/event/")
        #expect(session.apiURL.absoluteString == "https://api.fastmail.com/jmap/api/")
    }

    @Test func downloadURL() throws {
        let session: Session = try JSONDecoder().decode(Session.self, from: data)
        #expect(session.downloadURLTemplate == "https://www.fastmailusercontent.com/jmap/download/{accountId}/{blobId}/{name}?type={type}")
        #expect(
            try session.downloadURL(account: "u7a51e404", blob: "b404e15a7", name: "file_name", type: "pdf").absoluteString
                == "https://www.fastmailusercontent.com/jmap/download/u7a51e404/b404e15a7/file_name?type=pdf")
        #expect(
            try session.downloadURL(account: "u7a51e404", blob: "b404e15a7", name: "file_name", type: "").absoluteString
                == "https://www.fastmailusercontent.com/jmap/download/u7a51e404/b404e15a7/file_name?type=")
        #expect(throws: URLError.self) {
            try session.downloadURL(account: "u7a51e404", blob: "b404e15a7", name: "", type: "")
        }
        #expect(throws: URLError.self) {
            try session.downloadURL(account: "u7a51e404", blob: "", name: "file_name", type: "")
        }
        #expect(throws: URLError.self) {
            try session.downloadURL(account: "", blob: "b404e15a7", name: "file_name", type: "")
        }
    }

    @Test func uploadURL() throws {
        let session: Session = try JSONDecoder().decode(Session.self, from: data)
        #expect(session.uploadURLTemplate == "https://api.fastmail.com/jmap/upload/{accountId}/")
        #expect(try session.uploadURL(account: "u7a51e404").absoluteString == "https://api.fastmail.com/jmap/upload/u7a51e404/")
        #expect(throws: URLError.self) {
            try session.uploadURL(account: "")
        }
    }
}

// swift-format-ignore
private let data: Data = """
{
    "state": "cyrus-0;p-67bb868361;s-68403d307e150478",
    "username": "toddheasley@fastmail.com",
    "eventSourceUrl": "https://api.fastmail.com/jmap/event/",
    "uploadUrl": "https://api.fastmail.com/jmap/upload/{accountId}/",
    "downloadUrl": "https://www.fastmailusercontent.com/jmap/download/{accountId}/{blobId}/{name}?type={type}",
    "primaryAccounts": {
        "urn:ietf:params:jmap:submission": "u7a51e404",
        "urn:ietf:params:jmap:core": "u7a51e404",
        "urn:ietf:params:jmap:mail": "u7a51e404",
        "https://www.fastmail.com/dev/maskedemail": "u7a51e404"
    },
    "capabilities": {
        "urn:ietf:params:jmap:submission": {},
        "urn:ietf:params:jmap:mail": {},
        "urn:ietf:params:jmap:core": {
            "maxSizeRequest": 10000000,
            "maxObjectsInSet": 4096,
            "maxConcurrentUpload": 10,
            "maxCallsInRequest": 50,
            "maxObjectsInGet": 4096,
            "maxConcurrentRequests": 10,
            "collationAlgorithms": [
                "i;ascii-numeric",
                "i;ascii-casemap",
                "i;octet"
            ],
            "maxSizeUpload": 250000000
        },
        "https://www.fastmail.com/dev/maskedemail": {}
    },
    "accounts": {
        "u7a51e404": {
            "isReadOnly": false,
            "accountCapabilities": {
                "urn:ietf:params:jmap:submission": {
                    "submissionExtensions": {},
                    "maxDelayedSend": 44236800
                },
                "urn:ietf:params:jmap:core": {},
                "urn:ietf:params:jmap:mail": {
                    "maxSizeMailboxName": 490,
                    "maxSizeAttachmentsPerEmail": 50000000,
                    "mayCreateTopLevelMailbox": true,
                    "maxMailboxDepth": null,
                    "emailQuerySortOptions": [
                        "receivedAt",
                        "from",
                        "to",
                        "subject",
                        "size",
                        "header.x-spam-score"
                    ],
                    "maxMailboxesPerEmail": 1000
                },
                "https://www.fastmail.com/dev/maskedemail": {}
            },
            "name": "toddheasley@fastmail.com",
            "isPersonal": true
        }
    },
    "apiUrl": "https://api.fastmail.com/jmap/api/"
}
""".data(using: .utf8)!
