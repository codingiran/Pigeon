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

    func writeMessage(_ message: Messaging?, for identifier: Identifier) throws {
        guard let message, !identifier.isEmpty else { return }
        let data = try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)
        var currentContext = session.applicationContext
        if let lastContext = lastContext {
            currentContext = currentContext.merging(lastContext) { $1 }
        }
        currentContext[identifier] = data
        lastContext = currentContext
        try session.updateApplicationContext(currentContext)
    }

    func message(for identifier: Identifier) throws -> Messaging? {
        guard let data = (session.receivedApplicationContext[identifier] ?? session.applicationContext[identifier]) as? Data else {
            return nil
        }
        let message = NSKeyedUnarchiver.unarchiveObject(with: data)
        return message
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
