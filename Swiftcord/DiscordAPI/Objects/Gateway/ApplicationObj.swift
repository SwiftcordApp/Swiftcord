//
//  ApplicationObj.swift
//  Creating a file called Application.swift causes a build error
//  Xcode, why didn't you tell me?
//
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

// Just to get things working, add full application later
struct PartialApplication: Codable, GatewayData {
    let id: Snowflake
    let flags: Int
}
