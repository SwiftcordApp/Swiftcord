//
//  ApplicationObj.swift
//  Creating a file called Application.swift causes a build error
//  Xcode, why didn't you tell me?
//
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

// Just to get things working, add full application later
public struct PartialApplication: Codable, GatewayData {
	public let id: Snowflake
	public let flags: Int
}
