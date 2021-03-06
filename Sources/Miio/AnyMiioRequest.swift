//
//  AnyMIIORequest.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation

public struct AnyMiioRequest: MiioRequest {
    public let method: Method
    public let params: ParamsConverible
    public var id: UInt
    public init(method: Method,
                params: ParamsConverible,
                id: UInt = 1) {
        self.method = method
        self.params = params
        self.id = id
    }
}
