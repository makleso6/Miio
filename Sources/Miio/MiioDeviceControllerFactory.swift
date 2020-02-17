//
//  MiioDeviceControllerFactory.swift
//  Miio
//
//  Created by Maksim Kolesnik on 15/02/2020.
//

import Foundation

public final class MiioDeviceControllerFactory: DeviceControllerFactory {
    
    private let device: Device
    public init(device: Device) {
        self.device = device
    }
    
    public func makeDeviceController() throws -> DeviceController {
        let handler = NIOChanelInboundHandler()
        let networkService = try NIONetworkService(handler: handler)
        let deviceController = MiioDeviceController(networkService: networkService,
                                                    device: device)
        handler.outboundHandler = deviceController
        
        return deviceController
    }
}
