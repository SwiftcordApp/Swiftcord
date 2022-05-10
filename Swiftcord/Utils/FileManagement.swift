//
//  FileManagement.swift
//  Swiftcord
//
//  Created by Anthony Ingle on 5/10/22.
//

import Foundation

// Remove cached files older than the specified number of hours
func clearCache(olderThan hours: Int) {
    do {
        if let directories = try? FileManager.default.contentsOfDirectory(atPath: FileManager.default.temporaryDirectory.path) {
            for directory in directories {
                
                let directoryURL = FileManager.default.temporaryDirectory.appendingPathComponent(directory)
                
                let directoryAttributes = try FileManager.default.attributesOfItem(atPath: directoryURL.path)
                
                if let creationDate = directoryAttributes[FileAttributeKey.creationDate] as? Date {
                    print(creationDate)
                    if let diff = Calendar.current.dateComponents([.hour], from: creationDate, to: Date()).hour, diff > hours {
                        try FileManager.default.removeItem(at: directoryURL)
                    }
                }
            }
        }
    }
    catch {
        print(error)
    }
}
