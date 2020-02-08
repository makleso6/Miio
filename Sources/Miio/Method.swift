//
//  Method.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation

public struct Method: RawRepresentable, Encodable, ExpressibleByStringLiteral {
    public typealias RawValue = String
    public typealias StringLiteralType = RawValue
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral: String) {
        self.rawValue = stringLiteral
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
}

extension Method {
    public static var getProp: Method { return "get_prop" }
}
