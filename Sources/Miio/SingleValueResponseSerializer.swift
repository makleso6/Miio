//
//  SingleValueResponseSerializer.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation
import AnyCodable

struct SingleValueResponseSerializer<T>: ResponseSerializer where T: Decodable {
    typealias EntityType = T
    func process(_ response: AnyCodable) throws -> EntityType {
        let data = try JSONEncoder().encode(response)
        let array = try JSONDecoder().decode([EntityType].self, from: data)
        guard let value = array.first else { throw ResponseSerializerError.emptyArray }
        return value
    }
}
