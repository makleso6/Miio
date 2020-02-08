//
//  NIORequest.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol NIORequest: Sequence where Iterator == IndexingIterator<[Element]>, Element == UInt8 {
    var packet: [Element] { get }
}

extension NIORequest {
    public func makeIterator() -> IndexingIterator<[Element]> {
        return packet.makeIterator()
    }
}


