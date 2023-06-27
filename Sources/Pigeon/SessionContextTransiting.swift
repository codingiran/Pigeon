//
//  SessionContextTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 13.0, watchOS 6.0, *)
class SessionContextTransiting: FileTransiting {
    private var session: WCSession?
    private var lastContext: [String: Any]?

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
        var currentContext = session?.applicationContext ?? [:]
        if let applicationContext = session?.applicationContext {
            currentContext = currentContext.merging(applicationContext) { $1 }
        }
        currentContext[identifier] = data
        lastContext = currentContext
        try session?.updateApplicationContext(currentContext)
    }

    override func messageObjectForIdentifier(_ identifier: String) throws -> Pigeon.Message? {
        guard let data = (session?.receivedApplicationContext[identifier] as? Data) ?? (session?.applicationContext[identifier] as? Data) else {
            return nil
        }
        let messageObject = NSKeyedUnarchiver.unarchiveObject(with: data) as? Pigeon.Message
        return messageObject
    }

    override func deleteContentForIdentifier(_ identifier: String) throws {
        lastContext?.removeValue(forKey: identifier)
        guard var currentContext = session?.applicationContext else { return }
        currentContext.removeValue(forKey: identifier)
        try session?.updateApplicationContext(currentContext)
    }

    override func deleteContentForAllMessages() throws {
        lastContext?.removeAll()
        try session?.updateApplicationContext([:])
    }
}

#endif
