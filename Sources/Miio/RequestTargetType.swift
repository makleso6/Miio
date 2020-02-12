//
//  RequestTargetType.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import Foundation

public protocol RequestTargetType: MiioRequest {
    associatedtype ResponseSerializerType: ResponseSerializer
    
    var serializer: ResponseSerializerType { get }
}

extension RequestTargetType {
    public var id: UInt { 0 }
}
