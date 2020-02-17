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

public extension Method {
    static var getProp: Method { return "get_prop" }
    static var setPower: Method { "set_power" }
    static var setMode: Method { "set_mode" }
    static var setDry: Method { return "set_dry" }
    static var setChildLock: Method { return "set_child_lock" }
    static var setLimitHum: Method { return "set_limit_hum" }
    static var setLevelFavorite: Method { return "set_level_favorite" }

    
}
