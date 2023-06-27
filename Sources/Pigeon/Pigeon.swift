//
//  Pigeon.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import CoreFoundation
import Foundation

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("Pigeon doesn't support Swift versions below 5.5.")
#endif

/// Current Pigeon version. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.1"

open class Pigeon {
    public enum TransitingType {
        case file
        case coordinatedFile
        @available(iOS 13.0, watchOS 6.0, *)
        case sessionContext
        @available(iOS 13.0, watchOS 6.0, *)
        case sessionMessage
        @available(iOS 13.0, watchOS 6.0, *)
        case sessionFile
    }

    public typealias Listener = (Pigeon.Message?) -> Void
    public typealias Message = NSCoding

    private var listenerBlocks: [String: Pigeon.Listener] = [:]
    private static let NotificationName = "PigeonNotificationName"
    private var applicationGroupIdentifier: String
    private var optionalDirectory: String?

    public var messenger: Transiting?

    public init(applicationGroupIdentifier: String, optionalDirectory: String? = nil, transitingType: TransitingType = .file) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
        self.optionalDirectory = optionalDirectory
        switch transitingType {
        case .file:
            self.messenger = FileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .coordinatedFile:
            self.messenger = CoordinatedFileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .sessionContext:
            if #available(iOS 13.0, watchOS 6.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionContextTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
#endif
            }
        case .sessionMessage:
            if #available(iOS 13.0, watchOS 6.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionMessageTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
#endif
            }
        case .sessionFile:
            if #available(iOS 13.0, watchOS 6.0, *) {
#if os(iOS) || os(watchOS)
                self.messenger = SessionFileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
#endif
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessageNotification), name: Notification.Name(Pigeon.NotificationName), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let center = CFNotificationCenterGetDarwinNotifyCenter() {
            CFNotificationCenterRemoveEveryObserver(center, Unmanaged.passUnretained(self).toOpaque())
        }
    }
}

public extension Pigeon {
    func passMessageObject(_ messageObject: Pigeon.Message, forIdentifier identifier: String) throws {
        try self.messenger?.writeMessageObject(messageObject, for: identifier)
        self.sendNotificationForMessageWithIdentifier(identifier)
    }

    func messageWithIdentifier(_ identifier: String) throws -> Pigeon.Message? {
        let messageObject = try self.messenger?.messageObjectForIdentifier(identifier)
        return messageObject
    }

#if swift(>=5.5)
#if canImport(_Concurrency)
    func clearMessageContentsForIdentifier(_ identifier: String) throws {
        try self.messenger?.deleteContentForIdentifier(identifier)
    }
#endif
#endif

    func clearAllMessageContents() throws {
        try self.messenger?.deleteContentForAllMessages()
    }

    func listenForMessageWithIdentifier(_ identifier: String, listener: Pigeon.Listener?) {
        self.listenerBlocks[identifier] = listener
        self.registerForNotificationsWithIdentifier(identifier)
    }

    func listenForMessageWithIdentifier(_ identifier: String) async -> Pigeon.Message? {
        return await withCheckedContinuation { cont in
            self.listenForMessageWithIdentifier(identifier) { message in
                cont.resume(returning: message)
            }
        }
    }

    func stopListeningForMessageWithIdentifier(_ identifier: String) {
        self.listenerBlocks.removeValue(forKey: identifier)
        self.unregisterForNotificationsWithIdentifier(identifier)
    }
}

private extension Pigeon {
    func sendNotificationForMessageWithIdentifier(_ identifier: String) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let userInfo = nil as CFDictionary?
        let deliverImmediately = true
        let name = CFNotificationName(identifier as CFString)
        CFNotificationCenterPostNotification(center, name, nil, userInfo, deliverImmediately)
    }

    func registerForNotificationsWithIdentifier(_ identifier: String) {
        self.unregisterForNotificationsWithIdentifier(identifier)
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = identifier as CFString
        let callback: CFNotificationCallback = { _, _, name, object, _ in
            guard let identifier = name?.rawValue as? String else { return }
            NotificationCenter.default.post(name: Notification.Name(Pigeon.NotificationName), object: object, userInfo: ["identifier": identifier])
        }
        CFNotificationCenterAddObserver(center, Unmanaged.passUnretained(self).toOpaque(), callback, name, nil, .deliverImmediately)
    }

    func unregisterForNotificationsWithIdentifier(_ identifier: String) {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = CFNotificationName(identifier as CFString)
        CFNotificationCenterRemoveObserver(center, Unmanaged.passUnretained(self).toOpaque(), name, nil)
    }

    @objc func didReceiveMessageNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo, let identifier = userInfo["identifier"] as? String else {
            return
        }
        let messageObject = try? self.messenger?.messageObjectForIdentifier(identifier)
        self.notifyListenerForMessage(messageObject, withIdentifier: identifier)
    }

    func listenerBlockForIdentifier(_ identifier: String) -> Pigeon.Listener? {
        return self.listenerBlocks[identifier]
    }
}

extension Pigeon: TransitingDelegate {
    public func notifyListenerForMessage(_ message: Pigeon.Message?, withIdentifier identifier: String) {
        guard let listener = self.listenerBlockForIdentifier(identifier) else { return }
#if swift(>=5.5)
#if canImport(_Concurrency)
        Task { @MainActor in
            listener(message)
        }
#else
        DispatchQueue.main.async {
            listener(message)
        }
#endif
#endif
    }
}
