//
//  DecodableResponseSerializer.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation
import AnyCodable

public struct DecodableResponseSerializer<T>: ResponseSerializer where T: Decodable {
    public typealias EntityType = T
    public func process(_ response: AnyCodable) throws -> EntityType {
        let data = try JSONEncoder().encode(response)
        let value = try JSONDecoder().decode(EntityType.self, from: data)
        return value
    }
    
    public init() {}
}
