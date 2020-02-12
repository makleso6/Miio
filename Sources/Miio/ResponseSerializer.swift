//
//  ResponseSerializer.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import AnyCodable

enum ResponseSerializerError: Error {
    case emptyArray
    case invalidType(Any.Type)
}

public protocol ResponseSerializer {
    associatedtype EntityType
    func process(_ response: AnyCodable) throws -> EntityType
}
