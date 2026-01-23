import NIOCore
import NIOIMAP

// Generic wrapper for void-result commands that succeed or fail only
struct VoidCommand: IMAPCommand {
    let command: Command

    init(_ command: Command) {
        self.command = command
    }

    // MARK: IMAPCommand
    typealias Result = Void
    typealias Handler = VoidResultHandler

    var name: String { command.debugDescription.lowercased() }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: command)
    }
}

// Generic handler for void-result commands that succeed or fail only
class VoidResultHandler: IMAPCommandHandler, @unchecked Sendable {

    // MARK: IMAPCommandHandler
    typealias InboundIn = Response
    typealias InboundOut = Response
    typealias Result = Void

    var clientBug: String? = nil
    let promise: EventLoopPromise<Result>
    let tag: String

    required init(tag: String, promise: EventLoopPromise<Result>) {
        self.promise = promise
        self.tag = tag
    }
}
