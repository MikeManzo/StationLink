//
//  PSNUser.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//


import SwiftUI
import AppKit

// MARK: - Models
struct PSNUser: Codable {
    let onlineId: String
    let accountId: String
    let avatarUrls: [AvatarUrl]?
    let aboutMe: String?
    let trophySummary: TrophySummary?
    
    struct AvatarUrl: Codable {
        let size: String
        let avatarUrl: String
    }
    
    struct TrophySummary: Codable {
        let level: Int
        let progress: Int?
        let earnedTrophies: TrophyCount?
        
        struct TrophyCount: Codable {
            let bronze: Int
            let silver: Int
            let gold: Int
            let platinum: Int
        }
    }
    
    // Computed property to get the large avatar URL
    var avatarUrl: String? {
        guard let url = avatarUrls?.first(where: { $0.size == "l" })?.avatarUrl ?? avatarUrls?.first?.avatarUrl else {
            return nil
        }
        // Convert HTTP to HTTPS for App Transport Security
        return url.replacingOccurrences(of: "http://", with: "https://")
    }
}
