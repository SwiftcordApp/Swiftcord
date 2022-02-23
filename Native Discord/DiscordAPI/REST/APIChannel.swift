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
    static func getChannel(id: Snowflake) async -> Channel? {
        return await getReq(path: "channels/\(id)")
    }
    
    // MARK: Get Channel Messages
    // GET /channels/{channel.id}/messages
    static func getChannelMsgs(
        id: Snowflake,
        limit: Int = 50,
        around: Snowflake? = nil,
        before: Snowflake? = nil,
        after: Snowflake? = nil
    ) async -> [Message]? {
        var query = [URLQueryItem(name: "limit", value: String(limit))]
        if around != nil { query.append(URLQueryItem(name: "around", value: around)) }
        else if before != nil {query.append(URLQueryItem(name: "before", value: before))}
        else if after != nil { query.append(URLQueryItem(name: "after", value: after)) }
        
        return await getReq(path: "channels/\(id)/messages", query: query)
    }
    
    // MARK: Get Channel Message
    // GET /channels/{channel.id}/messages/{message.id}
    static func getChannelMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async -> Message? {
        return await getReq(path: "channels/\(id)/messages/\(msgID)")
    }
}
