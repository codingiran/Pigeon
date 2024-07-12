//
//  Pigeon.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import CoreFoundation
import Foundation
import SCFNotification

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("Pigeon doesn't support Swift versions below 5.5.")
#endif

/// Current Pigeon version 0.0.6. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.6"

public typealias Messaging = Any
public typealias Identifier = String
public typealias ReplyHandler = (Messaging?) -> Void
public typealias ReplyAction = (Messaging?) throws -> Void
public typealias Listener = (Messaging?, @escaping ReplyAction) -> Void

open class Pigeon {
    public enum TransitingType {
        case file
        case coordinatedFile
        @available(iOS 11.0, watchOS 4.0, *)
        case sessionContext
        @available(iOS 11.0, watchOS 4.0, *)
        case sessionMessage
        @available(iOS 11.0, watchOS 4.0, *)
        case sessionFile
    }

    let darwinNotificationCenter = SCFNotificationCenter.darwinNotify

    private var applicationGroupIdentifier: String
    private var optionalDirectory: String?

    public var messenger: Transiting?

    public init(applicationGroupIdentifier: String, optionalDirectory: String? = "Pigeon", transitingType: TransitingType = .file) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
        self.optionalDirectory = optionalDirectory
        switch transitingType {
        case .file:
            self.messenger = FileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .coordinatedFile:
            self.messenger = CoordinatedFileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .sessionContext:
            if #available(iOS 11.0, watchOS 4.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionContextTransiting()
#endif
            }
        case .sessionMessage:
            if #available(iOS 11.0, watchOS 4.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionMessageTransiting()
#endif
            }
        case .sessionFile:
            if #available(iOS 11.0, watchOS 4.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionFileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
#endif
            }
        }
    }

    deinit {
        darwinNotificationCenter.removeEveryObserver(observer: self)
    }
}

// MARK: - Public methods

public extension Pigeon {
    func passMessage(_ message: Messaging?, for identifier: Identifier, replyHandler: ReplyHandler? = nil) throws {
        try self.messenger?.writeMessage(message, for: identifier)
        sendNotification(for: identifier)
        if let replyHandler {
            self.listenMessage(for: identifier.replied) { message, _ in
                replyHandler(message)
            }
        }
    }

    func message(for identifier: Identifier) throws -> Messaging? {
        let messageObject = try self.messenger?.message(for: identifier)
        return messageObject
    }

    func listenMessage(for identifier: Identifier, listener: Listener?) {
        registerNotifications(for: identifier, listener: listener)
    }

    func stopListeningMessage(for identifier: Identifier) {
        unregisterNotifications(for: identifier)
    }

    func clearMessageContents(for identifier: Identifier) throws {
        try self.messenger?.deleteContent(for: identifier)
    }

    func clearAllMessageContents() throws {
        try self.messenger?.deleteContentForAllMessages()
    }
}

// MARK: - Private methods

private extension Pigeon {
    func sendNotification(for identifier: Identifier) {
        let userInfo = [String: Any]() as CFDictionary
        self.darwinNotificationCenter.postNotification(name: identifier.notificationName, userInfo: userInfo, deliverImmediately: true)
    }

    func registerNotifications(for identifier: Identifier, listener: Listener?) {
        self.unregisterNotifications(for: identifier)
        self.darwinNotificationCenter.addObserver(observer: self, name: identifier.notificationName, suspensionBehavior: .deliverImmediately) { [weak self] _, _, name, _, _ in
            guard let self, let identifier = name?.rawValue as? String else { return }
            let replyAction = self.replyAction(for: identifier)
            let message = try? self.messenger?.message(for: identifier)
            listener?(message, replyAction)
        }
    }

    func unregisterNotifications(for identifier: Identifier) {
        self.darwinNotificationCenter.removeObserver(observer: self, name: identifier.notificationName)
    }

    func replyAction(for identifier: Identifier) -> ReplyAction {
        return { [weak self] reply in
            try self?.passMessage(reply, for: identifier.replied)
        }
    }
}
