//
//  MIIORequest.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation
import AnyCodable

public protocol MiioRequest: Encodable {
    var id: UInt { get }
    var method: Method { get }
    var params: ParamsConverible { get }
}

private enum MiioRequestCodingKeys: String, CodingKey {
    case id, method, params
}

extension MiioRequest {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MiioRequestCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(params.paramsValue, forKey: .params)
    }
}
