import NIO
import Foundation
import Logging



//struct Packet {
//    let date: Date
//    let timeStamap: UInt32
//
//    init(data: Data) throws {
//        date = Date()
//        timeStamap = data.readUInt32BE(12)
//    }
//}





public struct Packet: Response {
    public typealias Element = UInt8
    public var packet: [UInt8]
    
    public init(data: Data) {
        self.packet = .init(data)
    }
    
    public init<S>(bytes: S) where S : Sequence, S.Element == UInt8 {
        self.packet = .init(bytes)
    }
}
















//class UpgradeEventHandler: ChannelOutboundHandler {
//    typealias OutboundIn = AddressedEnvelope<ByteBuffer>
//    typealias OutboundOut = AddressedEnvelope<ByteBuffer>
//
//    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
//        let addressedEnvelope = unwrapOutboundIn(data)
//        let handler = EchoHandler(outboundOut: addressedEnvelope)
//        context.channel.pipeline.addHandler(handler)
//        .whenComplete({ (result) in
//            context.writeAndFlush(data, promise: promise)
//        })
//    }
//}

