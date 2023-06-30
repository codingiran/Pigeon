//
//  Transiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

public protocol Transiting {
    func writeMessageObject(_ object: Messaging?, for identifier: Identifier) throws
    func message<M>(of type: M.Type, for identifier: Identifier) throws -> M? where M: Messaging
    func deleteContent(for identifier: Identifier) throws
    func deleteContentForAllMessages() throws
}
