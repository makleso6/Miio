//
//  ParamsConverible.swift
//  Miio
//
//  Created by Maksim Kolesnik on 11/02/2020.
//

import Foundation
import AnyCodable

public protocol ParamsConverible {
    var paramsValue: AnyCodable { get }
}

extension String: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension UInt: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension UInt8: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension UInt16: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension UInt32: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Int: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Int8: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Int16: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Int32: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Bool: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Double: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension Float: ParamsConverible {
    public var paramsValue: AnyCodable { .init([self]) }
}

extension ParamsConverible where Self: RawRepresentable, Self.RawValue == String {
    public var paramsValue: AnyCodable { .init([rawValue]) }
}

extension Array {
    public var paramsValue: AnyCodable { .init(self) }    
}
