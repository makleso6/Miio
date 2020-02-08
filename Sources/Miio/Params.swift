//
//  Params.swift
//  CNIOAtomics
//
//  Created by Maksim Kolesnik on 07/02/2020.
//

import Foundation

public struct Params: Sequence, Encodable, RawRepresentable, ExpressibleByArrayLiteral, ExpressibleByStringLiteral {
    
    public struct Param: RawRepresentable, Encodable, ExpressibleByStringLiteral {
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
    
    public typealias ArrayLiteralElement = Param
    public typealias StringLiteralType = Element.StringLiteralType
    public typealias RawValue = Elements
    public typealias Element = Param
    public typealias Elements = [Element]

    public var rawValue: Elements
    
    public init(arrayLiteral elements: Params.Param...) {
        self.rawValue = elements
    }
        
    public init(rawValue: Elements) {
        self.rawValue = rawValue
    }
    public init(stringLiteral: StringLiteralType) {
        self.rawValue = .init(arrayLiteral: .init(stringLiteral: stringLiteral))
    }
            
    public func makeIterator() -> IndexingIterator<[Param]> {
        return rawValue.makeIterator()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Params.Param {
    public static var mode: Params.Param { return "mode" }
}
