//
//  SessionContextTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 11.0, watchOS 4.0, *)
class SessionContextTransiting: Transiting {
    private var session = WCSession.default
    private var lastContext: [String: Any]?

    required init() {
        assert(session.delegate != nil, "WCSession's delegate is required to be set before you can send messages. Please initialize the MMWormholeSession sharedListeningSession object prior to creating a separate wormhole using the MMWormholeSessionTransiting classes.")
    }

    func writeMessageObject(_ object: Messaging?, for identifier: Identifier) throws {
        guard let object, !identifier.isEmpty else { return }
        let data = try object.messageData
        var currentContext = session.applicationContext
        if let lastContext = lastContext {
            currentContext = currentContext.merging(lastContext) { $1 }
        }
        currentContext[identifier] = data
        lastContext = currentContext
        try session.updateApplicationContext(currentContext)
    }

    func message<M>(of type: M.Type, for identifier: Identifier) throws -> M? where M: Messaging {
        guard let data = (session.receivedApplicationContext[identifier] ?? session.applicationContext[identifier]) as? Data else {
            return nil
        }
        let messageObject = try M(messageData: data)
        return messageObject
    }

    func deleteContent(for identifier: Identifier) throws {
        lastContext?.removeValue(forKey: identifier)
        var currentContext = session.applicationContext
        currentContext.removeValue(forKey: identifier)
        try session.updateApplicationContext(currentContext)
    }

    func deleteContentForAllMessages() throws {
        lastContext?.removeAll()
        try session.updateApplicationContext([:])
    }
}

#endif
