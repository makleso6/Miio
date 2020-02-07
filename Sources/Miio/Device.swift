//
//  Device.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public struct Device: Hashable {
    
    public var id: UInt32?
    public var ipAddress: String
    public var token: String
    
    public init(id: UInt32? = nil,
                ipAddress: String,
                token: String) {
        self.id = id
        self.ipAddress = ipAddress
        self.token = token
    }
}
