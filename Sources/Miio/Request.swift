//
//  Request.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol Request: Sequence where Iterator == IndexingIterator<[Element]>, Element == UInt8 {
    var packet: [Element] { get }
}

extension Request {
    public func makeIterator() -> IndexingIterator<[Element]> {
        return packet.makeIterator()
    }
}

public struct MIIORequest {
    public let method: String
    public let params: [String]
    
    public init(method: String,
                params: [String]) {
        self.method = method
        self.params = params
    }
}
