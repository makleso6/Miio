//
//  Handshake.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public struct Handshake: NIORequest {
    public var packet: [UInt8]
    public init() {
        packet = .init(repeating: 0, count: 32)
        packet[0] = 0x21
        packet[1] = 0x31
        packet[3] = 0x20
        for index in 4..<32 {
            packet[index] = 0xff
        }
    }
}
