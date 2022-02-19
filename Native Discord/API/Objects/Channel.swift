//
//  Channel.swift
//  Native Discord
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

enum ChannelType: Int, Codable {
    case text = 0
    case dm = 1
    case voice = 2
    case groupDM = 3
    case category = 4
    case news = 5
    case store = 6 // Depreciated game-selling channel
    case newsThread = 10
    case publicThread = 11
    case privateThread = 12
    case stageVoice = 13
}

struct Channel: Codable {
    
}
