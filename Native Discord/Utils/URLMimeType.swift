//
//  URLMimeType.swift
//  Native Discord
//
//  Created by Vincent Kwok on 26/2/22.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}
