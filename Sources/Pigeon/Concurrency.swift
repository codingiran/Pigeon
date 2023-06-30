//
//  Concurrency.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/28.
//

#if compiler(>=5.6.0) && canImport(_Concurrency)

import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension Pigeon {
    func listenMessage(for identifier: Identifier) async -> Messaging? {
        return await withCheckedContinuation { cont in
            self.listenMessage(for: identifier) { _, message in
                cont.resume(returning: message)
            }
        }
    }
}

#endif
