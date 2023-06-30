//
//  SessionListener.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

#if os(iOS) || os(watchOS)

import WatchConnectivity

@available(iOS 11.0, watchOS 4.0, *)
open class SessionListener: NSObject {
    public var shared = SessionListener()
    override private init() {
        super.init()
    }

    private let session = WCSession.default
}

extension SessionListener: WCSessionDelegate {
    @available(iOS 11.0, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {}

    @available(iOS 11.0, *)
    public func sessionDidDeactivate(_ session: WCSession) {}

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    public func session(_ session: WCSession, didReceive file: WCSessionFile) {}

    public func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {}
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {}

    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {}
}

#endif
