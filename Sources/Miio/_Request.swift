//
//  _Request.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import AnyCodable

public protocol _Request: RequestType {

    var _id: UInt { get }

    var _method: String { get }

    var _params: AnyCodable { get }
}
