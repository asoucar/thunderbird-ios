import Foundation
@testable import JMAP
import Testing

struct LocaleTests {
    @Test func acceptedLanguages() {
        #expect(Locale.acceptedLanguages().hasPrefix(Locale.preferredLanguages.first ?? "*"))
        #expect(Locale.acceptedLanguages().hasSuffix("*;q=0.5"))
    }
}
