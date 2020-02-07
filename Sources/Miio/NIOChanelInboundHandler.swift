//
//  MiioChanelInboundHandler.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import NIO
import Logging

public final class NIOChanelInboundHandler: ChannelInboundHandler, Logable {
    
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    public typealias ResultType = Result<(AddressedEnvelope<ByteBuffer>), Error>
    public weak var outboundHandler: OutboundHandler?
    
    public init() { }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let addressedEnvelope = unwrapInboundIn(data)
        loger.debug("\(String(describing: addressedEnvelope.remoteAddress.ipAddress))")
        outboundHandler?.recive(result: .success(addressedEnvelope))
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        loger.debug("channelReadComplete")
        context.flush()
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        loger.error("\(error)")
        outboundHandler?.recive(result: .failure(error))
        context.close(promise: nil)
    }
}
