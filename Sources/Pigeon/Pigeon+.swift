//
//  Pigeon+.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

public extension Pigeon {
    enum Error: LocalizedError, Sendable {
        case applicationGroupIdentifierNotConfigured
        case messageIdentifierInvalid
        case sessionUnReachable
        case fileCoordinatorFailed(String)

        public var errorDescription: String? {
            switch self {
            case .applicationGroupIdentifierNotConfigured:
                return "ApplicationGroupIdentifier is not configured"
            case .messageIdentifierInvalid:
                return "Message idetifier is empty or invalid"
            case .sessionUnReachable:
                return "WCSession is unreachable"
            case .fileCoordinatorFailed(let error):
                return "FileCoordinator failed with error: \(error)"
            }
        }
    }
}

public extension Identifier {
    var notificationName: CFNotificationName { CFNotificationName(self as CFString) }
    var replied: Identifier { self + "_pigeon_replied" }
}

extension URL {
    var filePath: String {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
            return self.path()
        } else {
            return self.path
        }
    }

    func appendingPath(_ path: String) -> URL {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
            return self.appending(path: path)
        } else {
            return self.appendingPathComponent(path)
        }
    }
}

extension FileManager {
    func fileExists(at url: URL) -> Bool {
        let path = url.filePath
        return self.fileExists(atPath: path)
    }
}
