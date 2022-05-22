//
//  MergePartialMessage.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 5/3/22.
//
//  Merges a PartialMessage and Message
//  Fields from PartialMessage are favored

import Foundation
import DiscordKit

extension Message {
    mutating func mergeWithPartialMsg(_ p: PartialMessage) {
        author = p.author ?? author
        member = p.member ?? member
        content = p.content ?? content
        edited_timestamp = p.edited_timestamp ?? edited_timestamp
        tts = p.tts ?? tts
        mention_everyone = p.mention_everyone ?? mention_everyone
        mentions = p.mentions ?? mentions
        mention_roles = p.mention_roles ?? mention_roles
        mention_channels = p.mention_channels ?? mention_channels
        attachments = p.attachments ?? attachments
        embeds = p.embeds ?? embeds
        reactions = p.reactions ?? reactions
        pinned = p.pinned ?? pinned
        webhook_id = p.webhook_id ?? webhook_id
        activity = p.activity ?? activity
        application = p.application ?? application
        application_id = p.application_id ?? application_id
        message_reference = p.message_reference ?? message_reference
        flags = p.flags ?? flags
        interaction = p.interaction ?? interaction
        thread = p.thread ?? thread
        components = p.components ?? components
        sticker_items = p.sticker_items ?? sticker_items
    }
}
