//
//  ApplicationObj.swift
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
