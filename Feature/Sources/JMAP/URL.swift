import Foundation

extension URL {

    /// Generate ``Session`` URL from (autodiscovery) components.
    ///
    /// All additional URLs and URL templates needed to implement a complete JMAP service are provided in the ``Session``.
    static func jmapSession(_ host: String, port: Int? = nil) throws -> Self {
        try jmap(host, port: port, path: "jmap/session")
    }

    static func jmap(_ host: String, port: Int? = nil, path: String? = nil) throws -> Self {
        var components: URLComponents = URLComponents()
        components.scheme = "https"
        guard !host.isEmpty else {
            throw URLError(.cannotFindHost)
        }
        components.host = host
        components.port = port
        if let path, !path.isEmpty {
            components.path = path.hasPrefix("/") ? path : "/\(path)"
        }
        guard let url: Self = components.url else {
            throw URLError(.unsupportedURL)
        }
        return url
    }
}
