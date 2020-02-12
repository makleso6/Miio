//
//  MIIOResponse.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import AnyCodable
import Foundation

public protocol MiioResponse: Decodable {
    var id: UInt { get }

    var result: Result<AnyCodable, ResponseError> { get }

}

extension MiioResponse {
    public var _id: UInt { id }
    public var _result: AnyCodable {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            do {
                let data = try JSONEncoder().encode(error)
                let anyCodable = try JSONDecoder().decode(AnyCodable.self, from: data)
                return anyCodable
            } catch {
                return .init(nilLiteral: ())
            }
        }
        
    }
}
