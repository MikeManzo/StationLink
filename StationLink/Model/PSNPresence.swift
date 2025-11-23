//
//  PSNPresence.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct PSNPresence: Codable {
    let availability: String?
    let lastAvailableDate: String?
    let primaryPlatformInfo: PlatformInfo?
    
    struct PlatformInfo: Codable {
        let onlineStatus: String
        let platform: String?
        let lastOnlineDate: String?
        let gameTitleInfo: GameInfo?
        
        struct GameInfo: Codable {
            let titleName: String?
            let npTitleId: String?
        }
    }
    
    // Computed properties for easier access
    var onlineStatus: String {
        primaryPlatformInfo?.onlineStatus ?? availability ?? "unknown"
    }
    
    var platform: String? {
        primaryPlatformInfo?.platform
    }
    
    var gameTitleInfo: PlatformInfo.GameInfo? {
        primaryPlatformInfo?.gameTitleInfo
    }
}
