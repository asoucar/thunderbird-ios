# Feature Libraries

## `Autoconfiguration`

[Thunderbird Autoconfiguration](https://wiki.mozilla.org/Thunderbird:Autoconfiguration), often just "autoconfig," is an XML syndication format where email service providers advertise public mail server settings.

### Library

`Autoconfigruation` library is designed to support email account setup in its parent project, [Thunderbird for iOS](https://github.com/thunderbird/thunderbird-ios), via `URLSession` data task:

```swift
import Autoconfiguration
import Foundation

let example: (config: ClientConfig, source: Source) = try await URLSession.shared.autoconfig("user123@aol.com")
```

Taking the default arguments, the above returns mail server settings for almost every email address in existence. Here's how it works:

1. Query all sources using the domain name from the given email address. If more than one client configuration is found, prefer the provider-provided configuration over the [Thunderbird "ISPDB" autoconfig database.](https://github.com/thunderbird/autoconfig)
2. If no configuration is found, the given email address is probably using a custom domain. Query [MX records](https://wikipedia.org/wiki/MX_record) for an underlying domain name, then re-query all sources using the underlying domain name.

MX records can be queried directly:

```swift
import Autoconfiguration

let records: [MXRecord] = try await DNSResolver.queryMX("thunderbird.net")
```

#### Domain Parsing

`Autoconfiguration` library uses the [Public Suffix List](https://publicsuffix.org) to parse domains from DNS host names:

```swift
import Autoconfiguration
import Foundation

let domain: String = try await URLSession.shared.domain(host: "smtp01.mail.example.com")
print(domain)  // example.com
```

#### Autodiscover(y)

`Autoconfiguration` supports [DNS service autodiscovery]((https://wikipedia.org/wiki/SRV_record)) for protocols like [JMAP](https://jmap.io) that don't use autoconfig:

```swift
import Autoconfiguration

let records: [SRVRecord] = try await DNSResolver.querySRV("example@thundermail.com")
```

[Autodiscover for Exchange](https://learn.microsoft.com/en-us/exchange/client-developer/exchange-web-services/autodiscover-for-exchange) is not supported at this time. Local and [MDM](https://support.apple.com/guide/deployment/welcome/web) configurations are not supported yet.

`Autoconfiguration` library depends on the [Swift Asynchronous DNS Resolver.](https://github.com/apple/swift-async-dns-resolver)

### Command-line interface

`autoconfig` is a bundled CLI demo of `Autoconfiguration` library:

```zsh
./autoconfig name@example.com -so
```

Email address is a required argument, plus two flags:

* `--save`: Save original config XML and JSON files to app working directory.
* `--open`: Open all config URLs in a browser; if saving, show files in Finder.

![](docs/autoconfig.png)

## `EmailAddress`

An [email address](https://wikipedia.org/wiki/Email_address) is a string with parts, formatted one of two specific ways: `Example Name <name@example.com>` or just `name@example.com`.

### Library

`EmailAddress` provides a shared model with conveniences for encoding and decoding addresses, as well as accessing the component parts:

```swift
import EmailAddress

let example: EmailAddress = "Example Name <name@example.com>"
print(example)  // Example Name <name@example.com>
print(example.value)  // name@example.com
print(example.label)  // Example Name
print(example.local)  // name
print(example.host)  // example.com
```

## `IMAP` and `SMTP`

Thunderbird supports sending and receiving email for most email providers through [Internet Message Access Protocol](https://wikipedia.org/wiki/Internet_Message_Access_Protocol) (IMAP) and [Simple Mail Transfer Protocol](https://wikipedia.org/wiki/Simple_Mail_Transfer_Protocol) (SMTP).

Both protocols use [TCP](https://wikipedia.org/wiki/Transmission_Control_Protocol) for transport, not HTTP; both libraries are built on top of [SwiftNIO.](https://opensource.apple.com/projects/swiftnio)

### `IMAP` Library

`IMAP` implementation glues NIOIMAP models and networking into an async/await interface.

```swift
import IMAP

let client = IMAPClient(Server(
    hostname: "imap.mail.example.com"
))
try await client.login(username: "user@example.com", password: "fake-appp-pass-word")
print(client.capabilities)  // "SASL-IR", "IMAP4rev1", "AUTH=XOAUTH2"…
try await client.logout()
```

`IMAP` library depends on [Swift NIOIMAP.](https://github.com/apple/swift-nio-imap)

### `SMTP` Library

`SMTP` implementation is based on `NIOSMTP` example project included in the [SwiftNIO examples repository.](https://github.com/apple/swift-nio-examples)

Configure `SMTPClient` with a `Server` to connect to; send one or more emails through the same server:

```swift
import Foundation
import SMTP

try await SMTPClient(Server(
    hostname: "smtp.mail.example.com",
    username: "username",
    password: "fake-appp-pass-word"
)).send(Email(
    sender: "sender@example.com",
    recipients: [
        "recipient@example.com"
    ],
    subject: "Example email subject",
    body: [
        "Body content parts can be plain text for now ;)".data(using: .utf8)!
    ]
))
```

`SMTP` library depends on [SwiftNIO](https://github.com/apple/swift-nio) for transport.

## `JMAP`

[JSON Meta Application Protocol](https://jmap.io) (JMAP)) is a modern, API-based approach to email that uses standard HTTP requests and responses with JSON serialization for transit.

`JMAP` feature library is a _client_ implementation of both [JMAP core](https://jmap.io/spec-core.html) and [JMAP mail](https://jmap.io/spec-mail.html) protocols, with functionality tailored for use in [Thunderbird for iOS.](https://github.com/thunderbird/thunderbird-ios)

## `MIME`

[Multipurpose Internet Mail Extensions](https://wikipedia.org/wiki/MIME) (MIME), colloquially "multipart data," extends basic, ASCII-text email to support text with various character encodings and binary objects like images, audio and video.

### Library

`MIME` feature library is a multipart message encoder and decoder. It's useful for the following purposes:

* Decoding IMAP- or POP-delivered email messages
* Encoding email messages for SMTP sending
* Encoding attachments for JMAP uploading

Modeled types adopt Swift [`RawRepresentable`](https://developer.apple.com/documentation/swift/RawRepresentable) to serialize and deserialize raw ASCII data representations. Each `Part` consists of a blob of ASCII [`Data`](https://developer.apple.com/documentation/foundation/data) and headers describing the data:

* `ContentType` specifies what the data blob _is_, e.g., `image/png` or `text/html; charset="utf-8"`.
* `ContentTransferEncoding` labels how the data is ASCII-encoded for transit, typically [base64](https://wikipedia.org/wiki/Base64) or [quoted-printable](https://wikipedia.org/wiki/Quoted-printable).
* `ContentDisposition` suggests whether the decoded data blob should appear inline as part of the message body or linked as an attachment.

Each `Part` can, itself, be multipart, allowing content to be grouped and nested. Multipart content types include a `Boundary` of 1-70 ASCII characters used to join and separate individual parts.

Parts roll up to a special top-level part, `Body`, which is parsed like any `Part`, but only accepts one of the two possible message body types, plain text or multipart. Decode `Body` from raw email message source:

```swift
import Foundation
import MIME

guard let url: URL = Bundle.module.url(forResource: "email-example", withExtension: "eml") else {
    throw URLError(.fileDoesNotExist)
}
let data: Data = try Data(contentsOf: url)
let body: Body = try Body(data)
print(body.contentType)  // multipart/alternative; boundary="_----------=_176171960423967"
print(body.contentTransferEncoding)  // Optional(8bit)
print(body.parts.count)  // 2
```

`Body` drops the `ContentDisposition` header and includes the MIME version header when encoded. Prepend the required SMTP headers and send:

```swift
guard let string: String = String(data: body.rawValue, encoding: .ascii) else {
    throw MIMEError.dataNotDecoded(body.rawValue, encoding: .ascii)
}
print(string)
// MIME-Version: 1.0
// Content-Type: multipart/alternative; boundary="_----------=_176171960423967"
//
// --_----------=_176171960423967
// Content-Disposition: inline
// Content-Transfer-Encoding: quoted-printable
// Content-Type: text/plain; charset="UTF-8"
//
// Hello,
// ...
```

#### Date Formatting

`MIME` includes a formatter that converts between [`Date`](https://developer.apple.com/documentation/foundation/date) and [RFC 822](https://www.rfc-editor.org/rfc/rfc822#section-5) `date-time` string representation.

```swift
import Foundation
import MIME

let formatter: RFC822DateFormatter = RFC822DateFormatter()
let date: Date = try formatter.date(from: "Sat,  6 Dec 2025 01:00:00 -0500 (EST)")
print(date.timeIntervalSince1970)  // 1765000800.0
let string: String = formatter.string(from: date, TimeZone(abbreviation: "EST")!)
print(string)  // Sat, 06 Dec 2025 01:00:00 -0500
```
