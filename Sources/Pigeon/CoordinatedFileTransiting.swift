//
//  CoordinatedFileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

class CoordinatedFileTransiting: FileTransiting {
    override func writeMessageObject(_ object: Messaging?, for identifier: Identifier) throws {
        guard let object, !identifier.isEmpty else { return }
        let data = try object.messageData
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

    override func message<M>(of type: M.Type, for identifier: Identifier) throws -> M? where M : Messaging {
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
        let messageObject = try M(messageData: data)
        return messageObject
    }
}
