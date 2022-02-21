//
//  APIChannel.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

extension DiscordAPI {
    // MARK: Get Channel
    // GET /channels/{channel.id}
    func getChannel(id: Snowflake) async -> Channel? {
        return await getReq(path: "channels/\(id)")
    }
    
    // MARK: Get Channel Messages
    // GET /channels/{channel.id}/messages
    func getChannelMsgs(
        id: Snowflake,
        limit: Int = 50,
        around: Snowflake? = nil,
        before: Snowflake? = nil,
        after: Snowflake? = nil
    ) async -> [Message]? {
        return await getReq(path: "channels/\(id)")
    }
    
    // MARK: Get Channel Message
    // GET /channels/{channel.id}/messages/{message.id}
    func getChannelMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async -> Message? {
        return await getReq(path: "channels/\(id)/messages/\(msgID)")
    }
}
