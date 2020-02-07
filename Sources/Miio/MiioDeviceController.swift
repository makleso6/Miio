//
//  MiioDeviceController.swift
//  Miio
//
//  Created by Maksim Kolesnik on 05/02/2020.
//

import Foundation
import NIO
import Logging
import Cryptor

public struct Info: Encodable {
    let method: String
    let id = 2
    let params: [String] = ["mode"]
    public init(method: String) {
        self.method = method
    }
}

public class MiioDeviceController: Logable {
    
    private enum Consts {
        static var port: Int = 54321
    }
    
    public typealias ResultType = Result<(AddressedEnvelope<ByteBuffer>), Error>
    public typealias OnResult = (ResultType) -> Void
    
    private var onHandshake: (() -> Void)?
    lazy var delayWorker: DelayWorker = {
        let delayWorker = ReadyDelayWorker()
        delayWorker.call()
        return delayWorker
    }()
    
    private var _buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 32)))
    private var deviceUptime: UInt32 = 0
    private var serverStamp: TimeInterval = 0
    private var isDiscovering = false
    private var device: Device
    private let networkService: NetworkService
    public init(networkService: NetworkService,
                device: Device) {
        self.networkService = networkService
        self.device = device
    }
    
    private var needsHandshake: Bool {
        //return ! this._token || (Date.now() - this._serverStampTime) > 120000;
        return true
    }
    
    private var tokenData: [UInt8] {
        CryptoUtils.byteArray(fromHex: self.device.token)
    }
    
    private var tokenKey: [UInt8]? {
        Digest(using:.md5).update(byteArray: tokenData)?.final()
    }
    
    private var tokenIV: [UInt8]? {
        tokenKey.flatMap({ Digest(using:.md5).update(byteArray: $0)?.update(byteArray: tokenData)?.final() })
    }
    
    private func proccess(response: AddressedEnvelope<ByteBuffer>) {
        
    }
    
    private func decrypt(response envelope: AddressedEnvelope<ByteBuffer>) {
        var _buffer = envelope.data
        _buffer.moveReaderIndex(to: 0)
        _buffer.moveWriterIndex(to: 32)
        
        let encrypted: [UInt8] = {
            var __buffer = envelope.data
            __buffer.moveReaderIndex(to: 32)
            return [UInt8](__buffer.readableBytesView)
        }()
        
        print("encrypted", encrypted)
        
        if
            let tokenKey = self.tokenKey,
            let tokenIV = self.tokenIV,
//            let encrypted2 = _buffer.readBytes(length: <#T##Int#>),
            let sliced = _buffer.getSlice(at: 0, length: 16)?.readableBytesView,
            let digest =  Digest(using:.md5)
                .update(byteArray: [UInt8](sliced))?
                .update(byteArray: tokenData)?
                .update(byteArray: encrypted)?
                .final() {
            print("checksum",digest)
            do {
                let data = try self.aes([UInt8](encrypted), key: tokenKey, iv: tokenIV, operation: .decrypt)
                print("data", data)
                let string = String(data: .init(data), encoding: .utf8)
                
                print("string", string)
            } catch {
                print(error)
            }
        }
        
    }
    
}


extension MiioDeviceController: DeviceController {
    
    public func handshake(completion: @escaping () -> Void) {
        self.onHandshake = completion
        do {
            isDiscovering = true
            try networkService.send(bytes: Handshake(),
                                    to: device.ipAddress,
                                    port: Consts.port)
        } catch {
            isDiscovering = false
            print(error)
        }
    }
    
    public func send<RequestType>(request: RequestType) where RequestType: Encodable {
        
        delayWorker.performDelay(execute: { [weak self] in
            guard let self = self else { return }
            var buffer = ByteBuffer(.init(self._buffer))
            
            // set 0x00 from 4 to 8
            buffer.setBytes([UInt8](repeating: 0x00, count: 4), at: 4)
            
            let seconds: UInt32 = UInt32(Date().timeIntervalSince1970) - UInt32(self.serverStamp) + self.deviceUptime + 1
            buffer.setInteger(seconds, at: 12)
            
            let tokenData = CryptoUtils.byteArray(fromHex: self.device.token)
            
            if
                let tokenKey = self.tokenKey,
                let tokenIV = self.tokenIV
            {
                do {
                    
                    let data = try JSONEncoder().encode(request)
                    let encrypt = try self.aes(.init(data), key: tokenKey, iv: tokenIV, operation: .encrypt)
                    buffer.setInteger(UInt16(encrypt.count + 32), at: 2)
                    
                    if
                        let sliced = buffer.getSlice(at: 0, length: 16)?.readableBytesView,
                        let digest = Digest(using:.md5).update(byteArray: .init(sliced))?.update(byteArray: tokenData)?.update(byteArray: encrypt)?.final()
                    {
                        buffer.setBytes(digest, at: 16)
                        
                        buffer.moveReaderIndex(to: 0)
                        buffer.moveWriterIndex(to: buffer.capacity)
                        
                        buffer.writeBytes(encrypt)//setBytes(encrypt, at: buffer.capacity)
                        print("final buffer", [UInt8](buffer.readableBytesView).map({ "\($0)" }).joined(separator: ","))
                        print(buffer)
                        let header = [UInt8](buffer.readableBytesView)
                        let final = header + encrypt
                        try self.networkService.send(bytes: final, to: self.device.ipAddress, port: Consts.port)
                    } else {
                        self.loger.warning("something goes wrong")
                    }
                } catch {
                    print(error)
                }
            } else {
                self.loger.warning("something goes wrong")
            }
        })
        
    }
    

    
    private func aes(_ bytes: [UInt8], key: [UInt8], iv: [UInt8], operation: StreamCryptor.Operation) throws -> [UInt8] {
        let cryptor = try StreamCryptor.init(operation: operation, algorithm: .aes128, options: [.pkcs7Padding], key: key, iv: iv)
        var result: [UInt8] = .init(repeating: 0, count: bytes.count)
        let updateResult = cryptor.update(byteArrayIn: bytes, byteArrayOut: &result)
        result = Array(result.prefix(updateResult.0))
        var final = result
        let finalResult = cryptor.final(byteArrayOut: &final)
        final = Array(final.prefix(finalResult.0))
        return result + final
    }
}

extension MiioDeviceController: OutboundHandler {
    public func recive(result: Result<(AddressedEnvelope<ByteBuffer>), Error>) {
        do {
            let envelope = try result.get()
            print("capacity: ", envelope.data.readableBytesView.count)
            print("readableBytesView: ", [UInt8](envelope.data.readableBytesView))
            guard let id = envelope.data.getInteger(at: 8, endianness: .big, as: UInt32.self) else { return }
            if let stamp = envelope.data.getInteger(at: 12, endianness: .big, as: UInt32.self) {
                self.deviceUptime = stamp
                self.serverStamp = Date().timeIntervalSince1970
                print("stamp: ",stamp)
            }
            print(id)

            var _buffer = envelope.data
            _buffer.moveReaderIndex(to: 0)
            _buffer.moveWriterIndex(to: 32)
            if isDiscovering, let slice = _buffer.getSlice(at: 0, length: 32) {
                self._buffer = slice
            } else {
                self.decrypt(response: envelope)
            }
        } catch {
            loger.error("\(error)")
        }
        
        if isDiscovering {
            onHandshake?()
            delayWorker.call()
        }
        
        isDiscovering = false

    }
}

struct Message {
    var buffer: ByteBuffer
    
    init(buffer: ByteBuffer) {
        self.buffer = buffer
    }
    
    
}


final class BlockGenerator<T> {
    typealias BlockType = (T) -> Void

    private let innerHandler: BlockType
    
    init(handler: @escaping BlockType) {
        innerHandler = handler
    }
    
    func run(_ value: T) {
        innerHandler(value)
    }
}

protocol DelayWorker: AnyObject {
    func reset()
    func call()
    func performDelay(execute block: @escaping () -> Void)
}

final class ReadyDelayWorker: DelayWorker {
    var blocks: [BlockGenerator<Void>] = []
    private var flag = false

    func performDelay(execute block: @escaping () -> Void) {
        if flag {
            block()
        } else {
            blocks.append(.init(handler: block))
        }
    }
    func reset() {
        flag = false
    }
}

extension ReadyDelayWorker {
    func call() {
        flag = true
        for block in blocks {
            block.run(())
        }
        blocks.removeAll()
    }
}


//    public func info() throws {
////        delayWorker.performDelay(execute: { [weak self] in
////            guard let self = self else { return }
////            var buffer = ByteBuffer(.init(self._buffer))
////        })
//
//        /*
//        let secondPassed = UInt32(Date().timeIntervalSince1970) - UInt32(self.serverStamp)
//        print("secondPassed", secondPassed)
//        let deviceUpTime = secondPassed + self.stamp
//        buffer.moveWriterIndex(to: 12)
//        buffer.writeInteger(deviceUpTime)
//        */
//
//        var packet: [UInt8] = .init(repeating: 0, count: 32)
//        packet[0] = 0x21
//        packet[1] = 0x31
//        packet[3] = 0x20
//        for index in 4..<32 {
//            packet[index] = 0xff
//        }
//        for index in 4..<8 {
//            packet[index] = 0x00
//        }
//
//        var buffer = ByteBuffer(.init(packet))
//
//        /*
//         let info = Info(method: "miIO.info")
//         let data = try JSONEncoder().encode(info)
//         let string = String(data: data, encoding: .utf8)
//         //        print(string)
//         */
//
//        let request = """
//{"method":"miIO.info","id":1}
//"""
//        let data = request.data(using: .utf8)!
//
//        let uptime: UInt32 = 103075
//        buffer.moveWriterIndex(to: 12)
//        buffer.writeInteger(uptime)
//        print("buffer with uptime", [UInt8](buffer.readableBytesView))
//
//        let tokenData = CryptoUtils.byteArray(fromHex: self.device.token)
//        if let tokenKey = Digest(using:.md5).update(byteArray: tokenData)?.final() {
//            if let tokenIV = Digest(using:.md5).update(byteArray: tokenKey)?.update(byteArray: tokenData)?.final() {
//
//                let encrypt = try self.aes(.init(data), key: tokenKey, iv: tokenIV)
//                print("encrypt", encrypt)
//                buffer.moveWriterIndex(to: 2)
////                buffer.writeInteger(UInt16(encrypt.count + 32))
//                buffer.setInteger(UInt16(encrypt.count + 32), at: 2)
////                buffer.moveWriterIndex(to: buffer.capacity)
//                print("buffer with encrypt count", [UInt8](buffer.readableBytesView))
////                print(buffer)
//                buffer.moveWriterIndex(to: 16)
//                buffer.moveReaderIndex(to: 0)
////                if let slice = buffer.readSlice(length: 16)
//                if let sliced = buffer.readSlice(length: 16)?.readableBytesView,
//                    let digest = Digest(using:.md5)
//                        .update(byteArray: .init(sliced))?
//                        .update(byteArray: tokenData)?
//                        .update(byteArray: encrypt)?
//                        .final() {
//                    print("sliced", [UInt8](sliced))
//                    print("digest", [UInt8](digest))
//                    buffer.moveWriterIndex(to: 16)
//                    buffer.writeBytes(digest)
//
//                    buffer.moveReaderIndex(to: 0)
//                    buffer.moveWriterIndex(to: buffer.capacity)
//
//                    print("buffer with digest", [UInt8](buffer.readableBytesView))
//                }
//            }
//        }
//    }
