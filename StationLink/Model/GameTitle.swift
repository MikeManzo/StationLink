//
//  GameTitle.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct GameTitle: Identifiable, Codable {
    let id: String // npCommunicationId or titleId
    let name: String
    let imageUrl: String?
    let platform: String?
    let lastPlayedDateTime: String?
    let playDuration: String?
    let progress: Int?
    let earnedTrophies: TrophyCount?
    let definedTrophies: TrophyCount?
    let npCommunicationId: String? // Used for fetching detailed trophies
    let npServiceName: String? // "trophy" for PS3/PS4/Vita, "trophy2" for PS5/PC
    
    struct TrophyCount: Codable {
        let bronze: Int
        let silver: Int
        let gold: Int
        let platinum: Int
    }
    
    var completionPercentage: Int {
        guard let earned = earnedTrophies, let defined = definedTrophies else { return 0 }
        let total = defined.bronze + defined.silver + defined.gold + defined.platinum
        let earnedTotal = earned.bronze + earned.silver + earned.gold + earned.platinum
        return total > 0 ? (earnedTotal * 100) / total : 0
    }
}
