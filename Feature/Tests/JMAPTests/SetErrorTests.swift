import Foundation
@testable import JMAP
import Testing

struct SetErrorTests {
    @Test func valueInit() throws {
        #expect(SetError(try JSONSerialization.jsonObject(with: data)) == .invalidProperties)
    }
}

// swift-format-ignore
private let data: Data = """
{
    "properties": [
        "name"
    ],
    "type": "invalidProperties"
}
""".data(using: .utf8)!
