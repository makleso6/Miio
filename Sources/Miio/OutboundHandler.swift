//
//  OutboundHandler.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import NIO

public protocol OutboundHandler: AnyObject {
    func recive(result: Result<(AddressedEnvelope<ByteBuffer>), Error>)
}
