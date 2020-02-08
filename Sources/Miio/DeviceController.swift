//
//  DeviceController.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol DeviceController {
    associatedtype RequestType: Encodable
    associatedtype ResponseType: Decodable
    func send(request: RequestType, completion: @escaping (Result<ResponseType, Error>) -> Void)
}
