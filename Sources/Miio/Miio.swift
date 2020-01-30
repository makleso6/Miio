import UDPBroadcastConnection
import Foundation

public protocol DeviceController {
    
}

struct Packet {
    let date: Date
    let timeStamap: UInt32
}

public class MiioDeviceController: DeviceController {
    let networkService: NetworkService
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func handshake() {
        var packet: [UInt8] = .init(repeating: 0, count: 32)
        packet[0] = 0x21
        packet[1] = 0x31
        packet[3] = 0x20
        for index in 4..<32 {
            packet[index] = 0xff
        }
        do {
            try networkService.send(bytes: packet)
        } catch {
            print(error)
        }
    }
    
}

public protocol NetworkService: AnyObject {
    func register(_ block: @escaping (Result<Data, Error>) -> Void)
    func send(data: Data) throws
    func send(bytes: [UInt8]) throws
}

public class UDPNetworkService: NetworkService {
    
    //    lazy var broadcastConnection: UDPBroadcastConnection = {
    //
    //        return <#value#>
    //    }()
    
    private var broadcastConnection: UDPBroadcastConnection?
    private var closure: ((Result<Data, Error>) -> Void)?
    public init() throws {
        broadcastConnection = try UDPBroadcastConnection(
            port: 54321,
            handler: { [weak self] (ipAddress: String, port: Int, response: Data) -> Void in
                guard let self = self else { return }
                print(self)
                print(ipAddress)
                print(response)
                let timestamp = response.readUInt32BE(12)
                print(timestamp)
                let id = response.readUInt32BE(8)
                print(id)
                self.closure?(.success(response))
            }, errorHandler: { [weak self] (error) in
                guard let self = self else { return }
                print(self)
                self.closure?(.failure(error))
                
        })
    }
    
    public func register(_ block: @escaping (Result<Data, Error>) -> Void) {
        self.closure = block
    }
    
    public func send(data: Data) throws {
        try broadcastConnection?.sendBroadcast(data)
    }
    
    public func send(bytes: [UInt8]) throws {
        try send(data: .init(bytes))
    }
    
    //    public func handshake(_ block: @escaping () -> Void) {
    ////        self.closure = block
//            var packet: [UInt8] = .init(repeating: 0, count: 32)
//            packet[0] = 0x21
//            packet[1] = 0x31
//            packet[3] = 0x20
//            for index in 4..<32 {
//                packet[index] = 0xff
//            }
    //
    //        let data = Data(packet)
    //
    ////        try? broadcastConnection?.sendBroadcast(data)
    //        print(packet)
    //    }
}

extension Data {
    
    func readUInt32BE(_ position: Int) -> UInt32 {
        var values = [UInt8](repeating: 0, count: count)
        copyBytes(to: &values, from: .init(uncheckedBounds: (position, count - position)))
        return UInt32(bigEndian: values.withUnsafeBytes { $0.load(as: UInt32.self) })
    }
}
