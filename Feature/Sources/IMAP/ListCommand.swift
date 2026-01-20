import NIOCore
import NIOIMAP

struct ListCommand: IMAPCommand {
    let options: [ReturnOption]
    let wildcard: Character

    init(options: [ReturnOption] = [], wildcard: Character) {
        self.options = options
        self.wildcard = wildcard
    }

    // MARK: IMAPCommand
    typealias Result = [Mailbox]
    typealias Handler = ListHandler

    static var name: String { "list" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .list(nil, reference: .reference, .mailbox(wildcard), options))
    }
}

class ListHandler: IMAPCommandHandler, @unchecked Sendable {

    // MARK: IMAPCommandHandler
    typealias InboundIn = Response
    typealias InboundOut = Response
    typealias Result = [Mailbox]

    var mailboxes: Result = []
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
                promise.succeed(mailboxes)
            }
        case .untagged(let payload):
            switch payload {
            case .mailboxData(.list(let mailbox)):
                mailboxes.append(mailbox)
            default:
                break
            }
        default:
            break
        }
        context.fireChannelRead(data)
    }
}

extension MailboxName {
    static var reference: Self { Self(ByteBuffer(string: "")) }
}

extension MailboxPatterns {
    static func mailbox(_ wildcard: Character = .wildcard) -> Self {
        .mailbox(ByteBuffer(string: "\(wildcard)"))
    }
}
