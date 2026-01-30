import Foundation

extension JSONDecoder {

    /// https://jmap.io/spec-core.html#the-date-and-utcdate-data-types
    convenience init(date decodingStrategy: DateDecodingStrategy) {
        self.init()
        dateDecodingStrategy = decodingStrategy
    }
}
