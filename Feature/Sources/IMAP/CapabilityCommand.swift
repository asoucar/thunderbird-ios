import NIOCore
import NIOIMAP

// Fetch advertised server capabilities
struct CapabilityCommand: IMAPCommand {

    // MARK: IMAPCommand
    typealias Result = [Capability]
    typealias Handler = CapabilityHandler

    static var name: String { "capability" }

    func tagged(_ tag: String) -> NIOIMAPCore.TaggedCommand {
        TaggedCommand(tag: tag, command: .capability)
    }
}

class CapabilityHandler: IMAPCommandHandler, @unchecked Sendable {

    // MARK: IMAPCommandHandler
    typealias InboundIn = Response
    typealias InboundOut = Response
    typealias Result = [Capability]

    var capabilities: Result = []
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
                promise.succeed(capabilities)
            }
        case .untagged(let payload):
            switch payload {
            case .capabilityData(let capabilities):
                self.capabilities = capabilities
            default:
                break
            }
        default:
            break
        }
        context.fireChannelRead(data)
    }
}
