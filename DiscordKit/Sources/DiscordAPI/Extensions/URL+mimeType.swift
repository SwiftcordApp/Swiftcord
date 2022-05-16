//
//  URL+.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 26/2/22.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
	var mimeType: String {
		UTType(filenameExtension: self.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
    }
}
