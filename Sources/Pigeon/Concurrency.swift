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
    func listenMessage<M>(of type: M.Type, for identifier: Identifier) async -> M? where M: Messaging {
        return await withCheckedContinuation { cont in
            self.listenMessage(for: identifier) { _, _, message in
                cont.resume(returning: message)
            }
        }
    }

    func listen(for identifier: Identifier) async {
        await withCheckedContinuation { cont in
            self.listen(for: identifier) { _, _ in
                cont.resume()
            }
        }
    }
}

#endif
