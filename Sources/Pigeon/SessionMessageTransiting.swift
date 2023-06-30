//
//  SessionMessageTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 11.0, watchOS 4.0, *)
class SessionMessageTransiting: Transiting {
    private var session = WCSession.default

    required init() {
        assert(session.delegate != nil, "WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.")
    }

    func writeMessageObject(_ object: Messaging?, for identifier: Identifier) throws {
        guard let object, !identifier.isEmpty else { return }
        let data = try object.messageData
        guard session.isReachable else {
            throw Pigeon.Error.sessionUnReachable
        }
        session.sendMessage([identifier: data], replyHandler: nil)
    }

    func message<M>(of type: M.Type, for identifier: Identifier) throws -> M? where M: Messaging { nil }

    func deleteContentForAllMessages() throws {}

    func deleteContent(for identifier: Identifier) throws {}
}

#endif
