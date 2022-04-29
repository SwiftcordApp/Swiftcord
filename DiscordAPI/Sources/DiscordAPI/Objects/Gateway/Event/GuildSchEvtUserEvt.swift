//
//  GuildSchEvtUserEvt.swift
//  Native Discord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

struct GuildSchEvtUserEvt: Codable, GatewayData {
    let guild_scheduled_event_id: Snowflake
    let user_id: Snowflake
    let guild_id: Snowflake
}
