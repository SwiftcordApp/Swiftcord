//
//  APIGuild.swift
//  Native Discord
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

extension DiscordAPI {
    // MARK: Get Guild
    // GET /guilds/{guild.id}
    static func getGuild(id: Snowflake) async -> Guild? {
        return await getReq(path: "guilds/\(id)")
    }
    
    // MARK: Get Guild Channels
    // GET /guilds/{guild.id}/channels
    static func getGuildChannels(id: Snowflake) async -> [Channel]? {
        return await getReq(path: "guilds/\(id)/channels")
    }
    
    // MARK: Get Guild Roles
    // GET /guilds/{guild.id}/roles
    static func getGuildRoles(id: Snowflake) async -> [Role]? {
        return await getReq(path: "guilds/\(id)/roles")
    }
}
