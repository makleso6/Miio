//
//  MIIORequest.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation

public protocol MIIORequest: Encodable {
    var method: Method { get }
    var params: Params { get }
    var id: UInt { get }
}

public struct AnyMIIORequest: MIIORequest, Encodable {
    private enum CodingKeys: String, CodingKey {
        case method, params, id
    }
    
    public let method: Method
    public let params: Params
    public var id: UInt
    public init(method: Method,
                params: Params,
                id: UInt = 1) {
        self.method = method
        self.params = params
        self.id = id
    }
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(method, forKey: .method)
//        try container.encode(id, forKey: .id)
//    }

    
}
