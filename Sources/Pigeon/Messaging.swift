//
//  Messaging.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/28.
//

// import Foundation

// public protocol Messaging {
//    init?(messageData: Data) throws
//    var messageData: Data { get throws }
// }
//
// public extension Messaging where Self: NSCoding {
//    init?(messageData: Data) throws {
//        guard let object = NSKeyedUnarchiver.unarchiveObject(with: messageData) as? Self else { return nil }
//        self = object
//    }
//
//    var messageData: Data? {
//        get throws {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
//            return data
//        }
//    }
// }
//
// public extension Messaging where Self: Encodable {
//    var messageData: Data {
//        get throws {
//            let data = try JSONEncoder().encode(self)
//            return data
//        }
//    }
// }
//
// public extension Messaging where Self: Decodable {
//    init?(messageData: Data) throws {
//        let object = try JSONDecoder().decode(Self.self, from: messageData)
//        self = object
//    }
// }
//
// extension Data: Messaging {
//    public init?(messageData: Data) throws { self = messageData }
//    public var messageData: Data { get throws { self } }
// }
//
// extension Bool: Messaging {}
// extension Int: Messaging {}
// extension Int8: Messaging {}
// extension Int16: Messaging {}
// extension Int32: Messaging {}
// extension Int64: Messaging {}
// extension UInt: Messaging {}
// extension UInt8: Messaging {}
// extension UInt16: Messaging {}
// extension UInt32: Messaging {}
// extension UInt64: Messaging {}
// extension Double: Messaging {}
// extension Float: Messaging {}
// extension String: Messaging {}
// extension URL: Messaging {}
// extension Date: Messaging {}
// extension UUID: Messaging {}
// extension Optional where Wrapped: Messaging {}
// extension Array: Messaging where Element: Codable {}
// extension Set: Messaging where Element: Codable {}
// extension Dictionary: Messaging where Key: Codable, Value: Codable {}

/// https://stackoverflow.com/a/38024025/5033196
// public extension Messaging where Self: BinaryInteger {
//    var messageData: Data {
//        get throws {
//            return withUnsafeBytes(of: Self.self) { Data($0) }
//        }
//    }
//
//    init?(messageData: Data) throws {
//        guard messageData.count == MemoryLayout<Self>.size else { return nil }
//        let object = messageData.withUnsafeBytes { $0.load(as: Self.self) }
//        self = object
//    }
// }
