//
//  MIIORequest.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation
import AnyCodable

public protocol MiioRequest: _Request {
    var id: UInt { get }
    var method: Method { get }
    var params: ParamsConverible { get }
}

private enum MiioRequestCodingKeys:String, CodingKey {
    case id, method, params
}

extension MiioRequest {
    public var _id: UInt { id }
    public var _method: String { method.rawValue }
    public var _params: AnyCodable { params.paramsValue }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MiioRequestCodingKeys.self)
        try container.encode(_id, forKey: .id)
        try container.encode(_method, forKey: .method)
        try container.encode(_params, forKey: .params)
    }
}
