//
//  APIMultipartFormBody.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 14/5/22.
//

import Foundation

extension DiscordAPI {
    static func createMultipartBody(
        with payloadJson: String?,
        boundary: String,
        attachments: [URL]
    ) -> Data {
        var body = Data()

        for (n, attachment) in attachments.enumerated() {
            let name = try! attachment.resourceValues(forKeys: [URLResourceKey.nameKey]).name!
            guard let attachmentData = try? Data(contentsOf: attachment) else {
                DiscordAPI.log.error("Could not get data of attachment #\(n)")
                continue
            }

            body.append("--\(boundary)\r\n")
            body.append(
                "Content-Disposition: form-data; name=\"files[\(n)]\"; filename=\"\(name)\"\r\n"
            )
            body.append("Content-Type: \(attachment.mimeType())\r\n\r\n")
            body.append(attachmentData)
            body.append("\r\n")
        }
        
        if let payloadJson = payloadJson {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"payload_json\"\r\nContent-Type: application/json\r\n\r\n")
            body.append("\(payloadJson)\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }
}
