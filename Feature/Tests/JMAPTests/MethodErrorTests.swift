import Foundation
@testable import JMAP
import Testing

struct MethodErrorTests {

    // MARK: Decodable
    @Test func decoderInit() throws {
        let errors: [MethodError] = try JSONDecoder().decode([MethodError].self, from: data)
        try #require(errors.count == 2)
        #expect(errors[0] == .accountNotSupportedByMethod)
        #expect(errors[1] == .unknownMethod)
    }
}

// swift-format-ignore
private let data: Data = """
[
    [
        "error",
        {
            "type": "accountNotSupportedByMethod"
        },
        ""
    ],
    [
        "error",
        {
            "type": "unknownMethod"
        },
        "call-id"
    ]
]
""".data(using: .utf8)!
