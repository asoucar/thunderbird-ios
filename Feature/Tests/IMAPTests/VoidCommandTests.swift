@testable import IMAP
import Testing

struct VoidCommandTests {
    @Test func name() {
        #expect(VoidCommand(.capability).name == "capability")
        #expect(VoidCommand(.close).name == "close")
        #expect(VoidCommand(.expunge).name == "expunge")
        #expect(VoidCommand(.logout).name == "logout")
        #expect(VoidCommand(.unselect).name == "unselect")
    }
}
