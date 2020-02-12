//
//  _Response.swift
//  Miio
//
//  Created by Maksim Kolesnik on 12/02/2020.
//

import AnyCodable

public protocol _Response: ResponseType {

    var _id: UInt { get }

    var _result: AnyCodable { get }
}
