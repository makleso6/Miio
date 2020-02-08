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

public struct UIntIterator: IteratorProtocol {
    
    private var value: UInt = 1
    
    public mutating func next() -> UInt? {
        if value > 10000 {
            value = 0
        }
        value += 50
        return value
    }
}

public enum DeviceControllerError: Error {
    case requestTimeOut
}

public class MiioDeviceController: Logable {
        
    private struct _IndexedRequest: MIIORequest {
        let method: Method
        let params: Params
        let id: UInt
        init(request: MIIORequest,
             id: UInt) {
            method = request.method
            params = request.params
            self.id = id
        }
    }
    
    private enum Consts {
        static var port: Int = 54321
    }
    
    public typealias ResultType = Result<ResponseType, Error>
    public typealias OnResult = (ResultType) -> Void
    
    private var onHandshake: ((Result<Void, Error>) -> Void)?
    lazy var delayWorker: DelayWorker = {
        return ReadyDelayWorker()
    }()
    
    lazy var iterator: UIntIterator = {
        return UIntIterator()
    }()
    
    private var _buffer: ByteBuffer = .init(.init([UInt8].init(repeating: 0, count: 32)))
    private var deviceUptime: UInt32 = 0
    private var serverStamp: TimeInterval = 0
    private var isDiscovering = false
    private var device: Device
    private let networkService: NetworkService
    
    private var handshakeTimer: DispatchSourceTimer?
    
    private var requestMap: [UInt: OnResult] = [:]
    private var timerMap: [UInt: DispatchSourceTimer] = [:]

    public init(networkService: NetworkService,
                device: Device) {
        self.networkService = networkService
        self.device = device
    }
    
    private var needsHandshake: Bool {
        return Date().timeIntervalSince1970 - serverStamp > 120
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
    
    public func decrypt(response buffer: ByteBuffer) {
        var _buffer = buffer
        _buffer.moveReaderIndex(to: 0)
        _buffer.moveWriterIndex(to: 32)

        
        let encrypted: [UInt8] = {
            var _buffer = buffer
            _buffer.moveReaderIndex(to: 32)
            return [UInt8](_buffer.readableBytesView)
        }()
                
        if
            let tokenKey = self.tokenKey,
            let tokenIV = self.tokenIV,
            let sliced = _buffer.getSlice(at: 0, length: 16)?.readableBytesView,
            let digest =  Digest(using:.md5)
                .update(byteArray: [UInt8](sliced))?
                .update(byteArray: tokenData)?
                .update(byteArray: encrypted)?
                .final() {
//            print("checksum",digest)
            do {
                let data = try self.aes([UInt8](encrypted), key: tokenKey, iv: tokenIV, operation: .decrypt)
//                print([UInt8](data))
//                guard let string = String(bytes: data, encoding: .utf8) else { return }
//                print("string", string)

//                let regular = try NSRegularExpression(pattern: "[\\x00-\\x09\\x0B-\\x0C\\x0E-\\x1F\\x7F-\\x9F]/g",
//                                                      options: NSRegularExpression.Options.caseInsensitive)
//                let replacedString =
//                regular.stringByReplacingMatches(in: string,
//                                                 options: [],
//                                                 range: NSMakeRange(0, string.count),
//                                                 withTemplate: "")
//                print("replacedString", replacedString)
//                print([UInt8](replacedString.data(using: .utf8)!))

                let response = try JSONDecoder().decode(ResponseType.self, from: .init(data))
                print(response)
                requestMap.removeValue(forKey: response.id)?(.success(response))
                timerMap.removeValue(forKey: response.id)?.cancel()
            } catch {
                print(error)
            }
        }
        
    }
    
}

extension MiioDeviceController: DeviceController {
    public typealias RequestType = AnyMIIORequest
    public typealias ResponseType = AnyMIIOResponse
    
    
    public func handshake(completion: @escaping (Result<Void, Error>) -> Void) {
        self.onHandshake = completion
        
        let timer = DispatchSource.makeTimerSource()
        handshakeTimer = timer
        timer.schedule(deadline: .now() + .seconds(2))
        timer.setEventHandler {
            timer.cancel()
            completion(.failure(DeviceControllerError.requestTimeOut))
        }
        timer.resume()
        
        do {
            isDiscovering = true
            try networkService.send(bytes: Handshake(),
                                    to: device.ipAddress,
                                    port: Consts.port)
        } catch {
            isDiscovering = false
        }
    }
    
    private func _send(request: RequestType, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        guard let id = self.iterator.next() else { return }
        delayWorker.performDelay(execute: { [weak self] in
            guard let self = self else { return }
            let _request = _IndexedRequest(request: request, id: id)
            self.requestMap[id] = completion
            
            let timer = DispatchSource.makeTimerSource()
            timer.schedule(deadline: .now() + .seconds(2))
            timer.setEventHandler {
                timer.cancel()
                completion(.failure(DeviceControllerError.requestTimeOut))
            }
            timer.resume()
            self.timerMap[id] = timer
            
            var buffer = ByteBuffer(.init(self._buffer))
            
            buffer.setBytes([UInt8](repeating: 0x00, count: 4), at: 4)
            
            let seconds: UInt32 = UInt32(Date().timeIntervalSince1970) - UInt32(self.serverStamp) + self.deviceUptime
            buffer.setInteger(seconds, at: 12)
            
            if
                let tokenKey = self.tokenKey,
                let tokenIV = self.tokenIV
            {
                do {
                    let data = try JSONEncoder().encode(_request)
                    let encrypt = try self.aes(.init(data), key: tokenKey, iv: tokenIV, operation: .encrypt)
                    buffer.setInteger(UInt16(encrypt.count + 32), at: 2)
                    
                    if
                        let sliced = buffer.getSlice(at: 0, length: 16)?.readableBytesView,
                        let digest = Digest(using:.md5).update(byteArray: .init(sliced))?.update(byteArray: self.tokenData)?.update(byteArray: encrypt)?.final()
                    {
                        buffer.setBytes(digest, at: 16)

                        buffer.moveReaderIndex(to: 0)
                        buffer.moveWriterIndex(to: buffer.capacity)
                        
                        buffer.writeBytes(encrypt)//setBytes(encrypt, at: buffer.capacity)
                        let header = [UInt8](buffer.readableBytesView)
                        
                        try self.networkService.send(bytes: header,
                                                     to: self.device.ipAddress,
                                                     port: Consts.port)
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
    
    public func send(request: RequestType, completion: @escaping (Result<ResponseType, Error>) -> Void) {
        
        if needsHandshake {
            handshake(completion: { [weak self] (result) in
                guard let self = self else { return }
                do {
                    try result.get()
                    self._send(request: request, completion: completion)

                } catch {
                    completion(.failure(error))
                }
            })
        } else {
            _send(request: request, completion: completion)
        }
                
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
            guard let id = envelope.data.getInteger(at: 8, endianness: .big, as: UInt32.self) else { return }
            if let stamp = envelope.data.getInteger(at: 12, endianness: .big, as: UInt32.self) {
                self.deviceUptime = stamp
                self.serverStamp = Date().timeIntervalSince1970
            }

            var buffer = envelope.data
            buffer.moveReaderIndex(to: 0)
            buffer.moveWriterIndex(to: 32)
            if isDiscovering, let slice = buffer.getSlice(at: 0, length: 32) {
                _buffer = slice
                delayWorker.call()
                handshakeTimer?.cancel()
                onHandshake?(.success(()))
            } else {
                decrypt(response: envelope.data)
            }
        } catch {
            loger.error("\(error)")
        }
        isDiscovering = false

    }
}
