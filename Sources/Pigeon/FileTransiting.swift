//
//  FileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

class FileTransiting: Transiting {
    var optionalDirectory: String?
    var applicationGroupContainerURL: URL?
    let fileManager = FileManager.default

    required init(applicationGroupIdentifier: String, optionalDirectory: String?) {
        self.optionalDirectory = optionalDirectory
        self.applicationGroupContainerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier)
        if applicationGroupContainerURL == nil {
            assertionFailure("App Group Capabilities may not be correctly configured for your project, or your appGroupIdentifier may not match your project settings. Check Project->Capabilities->App Groups. Three checkmarks should be displayed in the steps section, and the value passed in for your appGroupIdentifier should match the setting in your project file.")
        }
    }

    func fileURLForIdentifier(_ identifier: Identifier) throws -> URL {
        let directoryURL = try messagePassingDirectoryURL()
        let fileName = identifier + ".archive"
        let fileURL = directoryURL.appendingPath(fileName)
        return fileURL
    }

    func messagePassingDirectoryURL() throws -> URL {
        guard let applicationGroupContainerURL = applicationGroupContainerURL else {
            throw Pigeon.Error.applicationGroupIdentifierNotConfigured
        }
        var directoryURL = applicationGroupContainerURL
        if let optionalDirectory = optionalDirectory {
            directoryURL = directoryURL.appendingPath(optionalDirectory)
        }
        if !fileManager.fileExists(at: directoryURL) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        return directoryURL
    }

    func writeMessageObject(_ object: Messaging?, for identifier: Identifier) throws {
        guard let object, !identifier.isEmpty else { return }
        let data = try object.messageData
        let fileURL = try fileURLForIdentifier(identifier)
        try data.write(to: fileURL, options: .atomic)
    }

    func message<M>(of type: M.Type, for identifier: Identifier) throws -> M? where M : Messaging {
        let fileURL = try fileURLForIdentifier(identifier)
        let data = try Data(contentsOf: fileURL)
        let messageObject = try M(messageData: data)
        return messageObject
    }

    func deleteContent(for identifier: Identifier) throws {
        let fileURL = try fileURLForIdentifier(identifier)
        try fileManager.removeItem(at: fileURL)
    }

    func deleteContentForAllMessages() throws {
        guard let _ = optionalDirectory else {
            return
        }
        let directoryURL = try messagePassingDirectoryURL()
        let messageFiles = try fileManager.contentsOfDirectory(atPath: directoryURL.filePath)
        for message in messageFiles {
            let messageURL = directoryURL.appendingPath(message)
            try fileManager.removeItem(at: messageURL)
        }
    }
}
