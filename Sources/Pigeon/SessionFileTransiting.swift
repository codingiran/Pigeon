//
//  SessionFileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 11.0, watchOS 4.0, *)
class SessionFileTransiting: FileTransiting {
    private let session = WCSession.default

    required init(applicationGroupIdentifier: String, optionalDirectory: String?) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        assert(session.delegate != nil, "WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.")
    }

    override func writeMessage(_ message: Messaging?, for identifier: Identifier) throws {
        guard let message else { return }
        if identifier.isEmpty {
            throw Pigeon.Error.messageIdentifierInvalid
        }
        let data = try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)
        guard session.isReachable else {
            throw Pigeon.Error.sessionUnReachable
        }
        var tempDir = try messagePassingDirectoryURL()
        tempDir = tempDir.appendingPath(identifier)
        try data.write(to: tempDir, options: .atomic)
        session.transferFile(tempDir, metadata: ["identifier": identifier])
    }
}

#endif
