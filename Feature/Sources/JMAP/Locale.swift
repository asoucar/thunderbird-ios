import Foundation

extension Locale {

    /// Generate a weighted `Accept-Language` HTTP request header from device user's configured locales.
    ///
    /// JMAP service should [localize user-facing strings](https://jmap.io/spec-core.html#localisation-of-user-visible-strings) according to header value.
    static func acceptedLanguages() -> String {
        var languages: [String] = []
        for (index, language) in preferredLanguages.prefix(5).enumerated() {
            languages.append("\(language)\(index > 0 ? ";q=0.\(10 - index)" : "")")
        }
        languages.append("*;q=0.5")
        return languages.joined(separator: ", ")
    }
}
