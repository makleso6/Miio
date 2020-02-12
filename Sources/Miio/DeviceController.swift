//
//  DeviceController.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol DeviceController {
    func send(request: MiioRequest, completion: @escaping (Result<MiioResponse, Error>) -> Void)
    func send<R>(request: R, result: @escaping (Result<R.ResponseSerializerType.EntityType, Error>) -> Void) where R: RequestTargetType

}
