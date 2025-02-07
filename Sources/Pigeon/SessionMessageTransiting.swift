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
class SessionMessageTransiting: Transiting, @unchecked Sendable {
    private var session = WCSession.default

    required init() {
        assert(session.delegate != nil, "WCSession's delegate is required to be set before you can send messages. Please initialize the SessionListener shared object prior to creating a separate pigeon using the SessionMessageTransiting classes.")
    }

    func writeMessage(_ message: Messaging?, for identifier: Identifier) throws {
        guard let message, !identifier.isEmpty else { return }
        let data = try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)
        guard session.isReachable else {
            throw Pigeon.Error.sessionUnReachable
        }
        session.sendMessage([identifier: data], replyHandler: nil)
    }

    func message(for identifier: Identifier) throws -> Messaging? { nil }

    func deleteContentForAllMessages() throws {}

    func deleteContent(for identifier: Identifier) throws {}
}

#endif
