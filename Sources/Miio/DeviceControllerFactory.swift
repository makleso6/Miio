//
//  DeviceControllerFactory.swift
//  AnyCodable
//
//  Created by Maksim Kolesnik on 15/02/2020.
//

import Foundation

public protocol DeviceControllerFactory {
    func makeDeviceController() throws -> DeviceController
}
