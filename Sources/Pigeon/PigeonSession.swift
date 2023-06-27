//
//  PigeonSession.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 13.0, watchOS 6.0, *)
open class PigeonSession: NSObject {
    public enum SessionType {
        case file
        case context
        case message
    }

    public enum ActivationState: Int, @unchecked Sendable {
        case notActivated = 0
        case inactive = 1
        case activated = 2
    }

    static let shared = PigeonSession(applicationGroupIdentifier: "", optionalDirectory: "", sessionType: .file)

    private var applicationGroupIdentifier: String
    private var optionalDirectory: String?
    
    public var messenger: Transiting?
    
    private let session = WCSession.default

    public init(applicationGroupIdentifier: String, optionalDirectory: String? = nil, sessionType: PigeonSession.SessionType = .file) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
        self.optionalDirectory = optionalDirectory
        switch sessionType {
        case .context:
            self.messenger = SessionContextTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .message:
            self.messenger = SessionMessageTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        case .file:
            self.messenger = SessionFileTransiting(applicationGroupIdentifier: applicationGroupIdentifier, optionalDirectory: optionalDirectory)
        }
    }

    public func activateSessionListening() {
        session.activate()
    }

    public var activationState: PigeonSession.ActivationState {
        PigeonSession.ActivationState(rawValue: session.activationState.rawValue) ?? .notActivated
    }
}

extension PigeonSession: WCSessionDelegate {
    @available(iOS 13.0, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    @available(iOS 13.0, *)
    public func sessionDidDeactivate(_ session: WCSession) {}

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    public func session(_ session: WCSession, didReceive file: WCSessionFile) {}

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {}
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {}

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {}
}

#endif
