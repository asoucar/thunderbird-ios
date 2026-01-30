import Foundation
@testable import JMAP
import Testing

struct URLTests {
    @Test func jmapSession() throws {
        #expect(try URL.jmapSession("api.fastmail.com").absoluteString == "https://api.fastmail.com/jmap/session")
        #expect(throws: URLError.self) {
            try URL.jmapSession("")
        }
    }

    @Test func jmap() throws {
        #expect(try URL.jmap("api.fastmail.com").absoluteString == "https://api.fastmail.com")
        #expect(try URL.jmap("api.fastmail.com", path: "/jmap/session").absoluteString == "https://api.fastmail.com/jmap/session")
        #expect(try URL.jmap("api.fastmail.com", path: "jmap/session").absoluteString == "https://api.fastmail.com/jmap/session")
        #expect(throws: URLError.self) {
            try URL.jmap("")
        }
    }
}
