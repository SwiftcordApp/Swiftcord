//
//  Levels.swift
//  Swiftcord
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

enum VerificationLevel: Int, Codable {
    case `none` = 0   // Unrestricted
    case low = 1      // Must have verified email
    case medium = 2   // Registeded on Discord for > 5 mins
    case high = 3     // Member of server for > 10 mins
    case veryHigh = 4 // Must have verified hp
}

enum MessageNotifLevel: Int, Codable {
    case all = 0
    case mentions = 1
}

enum ExplicitContentFilterLevel: Int, Codable {
    case disabled = 0
    case withoutRoles = 1 // Scan messages from members without roles
    case all = 2 // Scan everyone's messages
}

enum MFALevel: Int, Codable {
    case `none` = 0
    case elevated = 1
}

enum NSFWLevel: Int, Codable {
    case `default` = 0
    case explicit = 1
    case `safe` = 2
    case ageRestricted = 3
}

enum PremiumLevel: Int, Codable {
    case `none` = 0
    case tier1 = 1
    case tier2 = 2
    case tier3 = 3
}
