//
//  MIIOResponse.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation

public protocol MIIOResponse: Decodable {
    var id: UInt { get }
}

public struct AnyMIIOResponse: MIIOResponse {
    public var id: UInt
    public init(id: UInt) {
        self.id = id
    }
}
