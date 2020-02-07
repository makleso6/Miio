//
//  Response.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol Response: Collection where Element == UInt8 {
    var packet: [Element] { get }
}

extension Response {
    public func makeIterator() -> IndexingIterator<[Element]> {
        return packet.makeIterator()
    }
    public func index(after i: Int) -> Int {
        return packet.index(after: i)
    }
    
    public subscript(position: Int) -> Element {
        return packet[position]
    }
    
    public var startIndex: Int {
        return packet.startIndex
    }
    
    public var endIndex: Int {
        return packet.endIndex
    }
}
