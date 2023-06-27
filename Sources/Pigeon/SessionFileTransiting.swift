//
//  SessionFileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 13.0, watchOS 6.0, *)
class SessionFileTransiting: FileTransiting {
    private var session: WCSession?

    required init(applicationGroupIdentifier: String, optionalDirectory: String?) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        self.session = WCSession.default
        guard let _ = session?.delegate else {
            assertionFailure("Pigeon: WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole usin g the MMWormholeSessionTransiting classes.")
            return
        }
    }

    override func writeMessageObject(_ messageObject: Pigeon.Message, for identifier: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: messageObject, requiringSecureCoding: false)
        guard let session = session, session.isReachable else {
            throw Pigeon.Error.sessionUnReachable
        }
        var tempDir = try messagePassingDirectoryURL()
        tempDir = tempDir.appendingPath(identifier)
        try data.write(to: tempDir, options: .atomic)
        session.transferFile(tempDir, metadata: ["identifier": identifier])
    }
}

#endif
