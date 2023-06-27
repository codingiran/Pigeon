//
//  FileTransiting.swift
//  Pigeon
//
//  Created by CodingIran on 2023/6/27.
//

import Foundation

class FileTransiting: Transiting {
    var applicationGroupIdentifier: String
    var optionalDirectory: String?
    let fileManager = FileManager.default

    required init(applicationGroupIdentifier: String, optionalDirectory: String?) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
        self.optionalDirectory = optionalDirectory
        checkAppGroupCapabilities()
    }

    func fileURLForIdentifier(_ identifier: String) throws -> URL {
        let directoryURL = try messagePassingDirectoryURL()
        let fileName = identifier + ".archive"
        let fileURL = directoryURL.appendingPath(fileName)
        return fileURL
    }

    func messagePassingDirectoryURL() throws -> URL {
        guard let appGroupContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier) else {
            throw Pigeon.Error.applicationGroupIdentifierNotConfigured
        }
        var directoryURL = appGroupContainer
        if let optionalDirectory = optionalDirectory {
            directoryURL = directoryURL.appendingPath(optionalDirectory)
        }
        if !fileManager.fileExists(at: directoryURL) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        return directoryURL
    }

    func writeMessageObject(_ messageObject: Pigeon.Message, for identifier: String) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: messageObject, requiringSecureCoding: false)
        let fileURL = try fileURLForIdentifier(identifier)
        try data.write(to: fileURL, options: .atomic)
    }

    func messageObjectForIdentifier(_ identifier: String) throws -> Pigeon.Message? {
        let fileURL = try fileURLForIdentifier(identifier)
        let data = try Data(contentsOf: fileURL)
        let messageObject = NSKeyedUnarchiver.unarchiveObject(with: data)
        return messageObject as? Pigeon.Message
    }

    func deleteContentForIdentifier(_ identifier: String) throws {
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

// MARK: - Check App Group Capabilities

private extension FileTransiting {
    func checkAppGroupCapabilities() {
        guard let _ = fileManager.containerURL(forSecurityApplicationGroupIdentifier: applicationGroupIdentifier) else {
            assertionFailure("App Group Capabilities may not be correctly configured for your project, or your appGroupIdentifier may not match your project settings. Check Project->Capabilities->App Groups. Three checkmarks should be displayed in the steps section, and the value passed in for your appGroupIdentifier should match the setting in your project file.")
            return
        }
    }
}
