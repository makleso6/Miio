//
//  AnyMiioResponse.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation
import AnyCodable

public struct AnyMiioResponse: MiioResponse {
    
    enum CodingKeys: String, CodingKey {
        case id, result, error
    }
    public var id: UInt
    public var result: Result<AnyCodable, ResponseError>
    public init(id: UInt,
                result: Result<AnyCodable, ResponseError>) {
        self.id = id
        self.result = result
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UInt.self, forKey: .id)
        if container.allKeys.contains(.error) {
            result = try .failure(container.decode(ResponseError.self, forKey: .error))
        } else if container.allKeys.contains(.result) {
            result = try .success(container.decode(AnyCodable.self, forKey: .result))
        } else {
            result = .failure(.init(code: 1, message: "invalid response"))
        }
    }
}
