//
//  Transiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

public protocol Transiting: Sendable {
    func writeMessage(_ message: Messaging?, for identifier: Identifier) throws
    func message(for identifier: Identifier) throws -> Messaging?
    func deleteContent(for identifier: Identifier) throws
    func deleteContentForAllMessages() throws
}
