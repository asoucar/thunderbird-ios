import Foundation
@testable import MIME
import Testing

struct StringTests {
    @Test func crlf() {
        #expect(String.crlf == "\r\n")
    }

    @Test func separator() {
        #expect(String.separator == "-")
    }

    @Test func ascii() {
        #expect("👎 NOT ASCII".ascii == nil)
        #expect("/@scii=12345...".ascii == "/@scii=12345...")
        #expect("".ascii == "")
    }

    @Test func capitalized() {
        #expect("when i was little".capitalized(.sentence) == "When i was little")
        #expect("when I was little".capitalized(.sentence) == "When I was little")
        #expect("when i was little".capitalized(.title) == "When I Was Little")
        #expect("when i was little".capitalized == "When I Was Little")
    }

    @Test func parameters() {
        #expect(
            "multipart/alternative; boundary=\"_----------=_17617196041979919223967\"".parameters == [
                "boundary": "_----------=_17617196041979919223967"
            ])
        #expect(
            "multipart/mixed;\nboundary=\"----=_Part_15950895_843396275.1764942606546\"".parameters == [
                "boundary": "----=_Part_15950895_843396275.1764942606546"
            ])
        #expect(
            "multipart/alternative;\nboundary=\"b1_dd99cd789bcc10ebb82bcc39304a9664\"".parameters == [
                "boundary": "b1_dd99cd789bcc10ebb82bcc39304a9664"
            ])
        #expect(
            "text/plain; charset=utf-8; charset=\"utf-8\"".parameters == [
                "charset": "utf-8"
            ])
        #expect(
            "text/html; charset=ISO-8859-1".parameters == [
                "charset": "ISO-8859-1"
            ])
        #expect(
            "inline; filename=mime-part.jpg; modification-date=\"Mon, 31 Oct 1977 08:14:00 +0000 (GMT)\"".parameters == [
                "filename": "mime-part.jpg",
                "modification-date": "Mon, 31 Oct 1977 08:14:00 +0000 (GMT)"
            ])
        #expect(
            "attachment; filename=\"mime-part.zip\"; creation-date=\"Mon, 31 Oct 1977 08:14:00 +0000 (GMT)\"; modification-date=\"Mon, 31 Oct 1977 03:14:00-0500\"".parameters == [
                "filename": "mime-part.zip",
                "creation-date": "Mon, 31 Oct 1977 08:14:00 +0000 (GMT)",
                "modification-date": "Mon, 31 Oct 1977 03:14:00-0500"
            ])
        #expect(
            "attachment; filename=\"mime-part.png\"".parameters == [
                "filename": "mime-part.png"
            ])
        #expect("inline".parameters == [:])
    }

    @Test func quotedPrintableInit() throws {
        #expect(try String(quotedPrintable: .quotedPrintable) == decodedQuotedPrintable)
        #expect(throws: MIMEError.self) {
            try String(quotedPrintable: .quotedPrintable, encoding: .ascii)
        }
    }

    @Test func decodingQuotedPrintable() throws {
        let quotedPrintable: String = String(data: .quotedPrintable, encoding: .ascii)!
            .replacingOccurrences(of: "=\r\n", with: "")
            .replacingOccurrences(of: "=\n", with: "")
        #expect(try quotedPrintable.decodingQuotedPrintable() == decodedQuotedPrintable)
        #expect(throws: MIMEError.self) {
            try quotedPrintable.decodingQuotedPrintable(to: .ascii)
        }
    }
}

private extension Data {
    static var quotedPrintable: Self { try! Bundle.module.data(forResource: "mime-part.html") }
}

// swift-format-ignore
private let decodedQuotedPrintable: String = """
<!DOCTYPE html>
<style>

    :root {
        color-scheme: light dark;
    }

</style>
<p>HTML MIME part with local <a href="#anchor">⚓️ link</a>, <a href="https://www.thunderbird.net/donate/mobile/?form=tfi">remote link</a> and remote image</p>
<p><img id="anchor" src="https://avatars.githubusercontent.com/u/15187237" alt="Thunderbird avatar"></p>

"""
