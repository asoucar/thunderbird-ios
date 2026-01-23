import NIOCore
import NIOIMAP

struct StatusCommand: IMAPCommand {
    let mailboxName: MailboxName
    let attributes: [MailboxAttribute]

    init(_ mailboxName: MailboxName, attributes: [MailboxAttribute] = MailboxAttribute.allCases) {
        self.mailboxName = mailboxName
        self.attributes = attributes
    }

    // MARK: IMAPCommand
    typealias Result = MailboxStatus
    typealias Handler = StatusHandler

    var name: String { "status" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .status(mailboxName, attributes))
    }
}

class StatusHandler: IMAPCommandHandler, @unchecked Sendable {

    // MARK: IMAPCommandHandler
    typealias InboundIn = Response
    typealias InboundOut = Response
    typealias Result = MailboxStatus

    var status: MailboxStatus = MailboxStatus()
    var clientBug: String? = nil
    let promise: EventLoopPromise<Result>
    let tag: String

    required init(tag: String, promise: EventLoopPromise<Result>) {
        self.promise = promise
        self.tag = tag
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let response: Response = unwrapInboundIn(data)
        clientBug = response.clientBug
        switch response {
        case .tagged(let taggedResponse):
            switch taggedResponse.state {
            case .bad(let text), .no(let text):
                promise.fail(IMAPError.commandFailed(text.text))
            case .ok:
                promise.succeed(status)
            }
        case .untagged(let payload):
            switch payload {
            case .mailboxData(.status(_, let status)):
                self.status = status
            default:
                break
            }
        default:
            break
        }
        context.fireChannelRead(data)
    }
}
