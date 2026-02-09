import Foundation
import NIOCore
import NIOIMAPCore

// Avoid republishing the entire (cluttered) NIOIMAP public interface with @_exported; instead
// Add specific NIOIMAP types to public interface as needed

public typealias Mailbox = MailboxInfo

extension Mailbox {
    public typealias Attribute = MailboxInfo.Attribute
    public typealias Name = MailboxName
    public typealias Status = MailboxStatus
}

extension MailboxName: @retroactive CustomStringConvertible {
    init(_ string: String) {
        self.init(ByteBuffer(string: string))
    }

    // MARK: CustomStringConvertible
    public var description: String { String(data: Data(bytes), encoding: .utf8) ?? "" }
}
