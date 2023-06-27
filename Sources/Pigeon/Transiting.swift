//
//  Transiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

public protocol Transiting {
    func writeMessageObject(_ messageObject: Pigeon.Message, for identifier: String) throws
    func messageObjectForIdentifier(_ identifier: String) throws -> Pigeon.Message?
    func deleteContentForIdentifier(_ identifier: String) throws
    func deleteContentForAllMessages() throws
}

public protocol TransitingDelegate {
    func notifyListenerForMessage(_ message: Pigeon.Message?, withIdentifier identifier: String)
}
