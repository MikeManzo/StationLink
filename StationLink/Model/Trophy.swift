//
//  Trophy.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct Trophy: Identifiable, Codable {
    let id: Int // trophyId
    let trophyType: String // "bronze", "silver", "gold", "platinum"
    let trophyName: String
    let trophyDetail: String
    let trophyIconUrl: String
    let trophyGroupId: String
    let hidden: Bool
    let earned: Bool
    let earnedDateTime: String?
    let trophyProgressTargetValue: String?
    let trophyRewardName: String?
    let trophyRewardImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "trophyId"
        case trophyType
        case trophyName
        case trophyDetail
        case trophyIconUrl
        case trophyGroupId
        case hidden
        case earned
        case earnedDateTime
        case trophyProgressTargetValue
        case trophyRewardName
        case trophyRewardImageUrl
    }
    
    var trophyColor: Color {
        switch trophyType.lowercased() {
        case "bronze":
            return .brown
        case "silver":
            return .gray
        case "gold":
            return .yellow
        case "platinum":
            return .cyan
        default:
            return .secondary
        }
    }
}

struct TrophyGroup: Identifiable, Codable {
    let id: String // trophyGroupId
    let trophyGroupName: String
    let trophyGroupDetail: String?
    let trophyGroupIconUrl: String
    let definedTrophies: TrophyCount
    let earnedTrophies: TrophyCount?
    let progress: Int?
    
    struct TrophyCount: Codable {
        let bronze: Int
        let silver: Int
        let gold: Int
        let platinum: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "trophyGroupId"
        case trophyGroupName
        case trophyGroupDetail
        case trophyGroupIconUrl
        case definedTrophies
        case earnedTrophies
        case progress
    }
}
