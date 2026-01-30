import Foundation
@testable import JMAP
import Testing

struct URLRequestTests {
    @Test func jmapAPI() throws {
        let request: URLRequest = try .jmapAPI(
            [
                Mailbox.GetMethod("u7a51e404")
            ], url: url, authorization: "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody?.count ?? 0 > 100)
        #expect(throws: Error.self) {
            try URLRequest.jmapAPI([], url: url, authorization: "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        }
        #expect(throws: Error.self) {
            try URLRequest.jmapAPI(
                [
                    Mailbox.GetMethod("u7a51e404")
                ], url: url, authorization: "")
        }
    }

    @Test func jmapSession() throws {
        let request: URLRequest = try .jmapSession(url.host()!, authorization: "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        #expect(request.url?.absoluteString == "https://api.fastmail.com/jmap/session")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        #expect(request.httpMethod == "GET")
    }

    @Test func setAuthorization() throws {
        var request: URLRequest = URLRequest(url: url)
        try request.setAuthorization("Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer fmu1-1e911257e86b1f194daa-0-a89faae5c11f")
    }

    @Test func setContentType() {
        var request: URLRequest = URLRequest(url: url)
        request.setContentType("text/html")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "text/html")
        request.setContentType()
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json; charset=utf-8")
    }

    @Test func setAccept() {
        var request: URLRequest = URLRequest(url: url)
        request.setAccept("text/xml")
        #expect(request.value(forHTTPHeaderField: "Accept") == "text/xml")
        request.setAccept()
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func setAcceptLanguage() {
        var request: URLRequest = URLRequest(url: url)
        request.setAcceptLanguage("en-US, es:q=0.9, *")
        #expect(request.value(forHTTPHeaderField: "Accept-Language") == "en-US, es:q=0.9, *")
        request.setAcceptLanguage()
        #expect(request.value(forHTTPHeaderField: "Accept-Language")?.hasSuffix("*;q=0.5") == true)
        #expect(request.value(forHTTPHeaderField: "Accept-Language")?.hasPrefix("*") == false)
    }
}

private let url: URL = URL(string: "https://api.fastmail.com/jmap/api/")!
