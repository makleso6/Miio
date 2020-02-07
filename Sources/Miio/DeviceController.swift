//
//  DeviceController.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation

public protocol DeviceController {
    func send<RequestType>(request: RequestType) where RequestType: Encodable
}
