//
//  CoordinatedFileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

class CoordinatedFileTransiting: FileTransiting, @unchecked Sendable {
    override func writeMessage(_ message: Messaging?, for identifier: Identifier) throws {
        guard let message, !identifier.isEmpty else { return }
        let data = try NSKeyedArchiver.archivedData(withRootObject: message, requiringSecureCoding: false)
        let fileURL = try fileURLForIdentifier(identifier)
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var nserror: NSError?
        var errorToThrow: Swift.Error?
        fileCoordinator.coordinate(writingItemAt: fileURL, error: &nserror) { url in
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                print("Pigeon CoordinatedFileTransiting could not write to file \(url), reason: \(error.localizedDescription).")
                errorToThrow = error
            }
        }
        if let nserror {
            throw Pigeon.Error.fileCoordinatorFailed(nserror.localizedDescription)
        }
        if let errorToThrow {
            throw Pigeon.Error.fileCoordinatorFailed(errorToThrow.localizedDescription)
        }
    }

    override func message(for identifier: Identifier) throws -> Messaging? {
        let fileURL = try fileURLForIdentifier(identifier)
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        var nserror: NSError?
        var errorToThrow: Swift.Error?
        var data: Data?
        fileCoordinator.coordinate(readingItemAt: fileURL, error: &nserror) { url in
            do {
                data = try Data(contentsOf: url)
            } catch {
                print("Pigeon CoordinatedFileTransiting could not read to file \(url), reason: \(error.localizedDescription).")
                errorToThrow = error
            }
        }
        if let nserror {
            throw Pigeon.Error.fileCoordinatorFailed(nserror.localizedDescription)
        }
        if let errorToThrow {
            throw Pigeon.Error.fileCoordinatorFailed(errorToThrow.localizedDescription)
        }
        guard let data else {
            return nil
        }
        let messageObject = NSKeyedUnarchiver.unarchiveObject(with: data)
        return messageObject
    }
}
