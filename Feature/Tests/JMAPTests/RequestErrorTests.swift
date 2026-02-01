import Foundation
@testable import JMAP
import Testing

struct RequestErrorTests {

    // MARK: Decodable
    @Test func decoderInit() throws {
        let errors: [RequestError] = try JSONDecoder().decode([RequestError].self, from: data)
        try #require(errors.count == 2)
        #expect(errors[0].code == .unknownCapability)
        #expect(errors[0].description == "Unknown capability; The request object used capability which is not supported by this server.")
        #expect(errors[1].code == .limit)
        #expect(errors[1].description == "Limit; The request is larger than the server is willing to process.")
    }
}

// swift-format-ignore
private let data: Data = """
[
    {
        "type": "urn:ietf:params:jmap:error:unknownCapability",
        "status": 400,
        "detail": "The request object used capability which is not supported by this server."
    },
    {
        "type": "urn:ietf:params:jmap:error:limit",
        "limit": "maxSizeRequest",
        "status": 400,
        "detail": "The request is larger than the server is willing to process."
    }
]
""".data(using: .utf8)!
