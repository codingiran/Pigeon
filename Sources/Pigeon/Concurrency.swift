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
    func messages(for identifier: Identifier) -> Pigeon.Messages {
        .init(pigeon: self, identifier: identifier)
    }

    final class Messages: AsyncSequence, @unchecked Sendable {
        /// The kind of elements streamed.
        public typealias Message = (message: Messaging?, replyAction: ReplyAction)
        public typealias Element = Message

        private var pigeon: Pigeon
        private var identifier: Identifier

        // MARK: Initialization

        init(pigeon: Pigeon, identifier: Identifier) {
            self.pigeon = pigeon
            self.identifier = identifier
        }

        public final func makeAsyncIterator() -> Iterator {
            .init(pigeon: self.pigeon, identifier: self.identifier)
        }

        /// The type of asynchronous iterator that produces elements of this
        /// asynchronous sequence.
        public typealias AsyncIterator = Pigeon.Messages.Iterator

        public struct Iterator: AsyncIteratorProtocol {
            private var pigeon: Pigeon
            private var identifier: Identifier
            private var iterator: PassthroughAsyncSequence<Element>.AsyncIterator
            private var passthroughAsyncSequence: PassthroughAsyncSequence<Element> = .init()

            init(pigeon: Pigeon, identifier: Identifier) {
                self.pigeon = pigeon
                self.identifier = identifier
                self.iterator = self.passthroughAsyncSequence.makeAsyncIterator()
                self.pigeon.listenMessage(for: self.identifier) { [passthroughAsyncSequence] message, replyAction in
                    passthroughAsyncSequence.yield((message, replyAction))
                }
            }

            public mutating func next() async -> Element? {
                guard let value = await self.iterator.next() else {
                    self.pigeon.stopListeningMessage(for: self.identifier)
                    return nil
                }
                return value
            }

            public typealias Element = Message
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct PassthroughAsyncSequence<Element>: AsyncSequence {
    private var stream: AsyncStream<Element>!
    private var continuation: AsyncStream<Element>.Continuation!

    // MARK: Initialization

    /// Creates an async sequence that broadcasts elements.
    public init() {
        self.stream = .init { self.continuation = $0 }
    }

    // MARK: AsyncSequence

    /// Creates an async iterator that emits elements of this async sequence.
    /// - Returns: An instance that conforms to `AsyncIteratorProtocol`.
    public func makeAsyncIterator() -> AsyncStream<Element>.Iterator {
        self.stream.makeAsyncIterator()
    }

    // MARK: API

    /// Yield a new element to the sequence.
    ///
    /// Yielding a new element will emit it through the sequence.
    /// - Parameter element: The element to yield.
    public func yield(_ element: Element) {
        self.continuation.yield(element)
    }

    /// Mark the sequence as finished by having it's iterator emit nil.
    ///
    /// Once finished, any calls to yield will result in no change.
    public func finish() {
        self.continuation.finish()
    }

    /// Emit one last element beford marking the sequence as finished by having it's iterator emit nil.
    ///
    /// Once finished, any calls to yield will result in no change.
    /// - Parameter element: The element to emit.
    public func finish(with element: Element) {
        self.continuation.finish(with: element)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension PassthroughAsyncSequence: Sendable where Element: Sendable {}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension AsyncStream.Continuation {
    /// Yield the provided value and then finish the stream.
    /// - Parameter value: The value to yield to the stream.
    func finish(with value: Element) {
        self.yield(value)
        self.finish()
    }
}

#endif
