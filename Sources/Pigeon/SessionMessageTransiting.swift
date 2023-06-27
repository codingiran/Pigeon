//
//  SessionMessageTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 13.0, watchOS 6.0, *)
class SessionMessageTransiting: FileTransiting {
    private var session: WCSession?

    required init(applicationGroupIdentifier: String, optionalDirectory: String?) {
        super.init(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        self.session = WCSession.default
        guard let _ = session?.delegate else {
            assertionFailure("Pigeon: WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.")
            return
        }
    }

    override func writeMessageObject(_ messageObject: Pigeon.Message, for identifier: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: messageObject, requiringSecureCoding: false)
        guard let session = self.session, session.isReachable else {
            throw Pigeon.Error.sessionUnReachable
        }
        session.sendMessage([identifier: data], replyHandler: nil)
    }

    override func messageObjectForIdentifier(_ identifier: String) throws -> Pigeon.Message? { nil }

    override func deleteContentForAllMessages() throws {}

    override func deleteContentForIdentifier(_ identifier: String) throws {}
}

#endif
