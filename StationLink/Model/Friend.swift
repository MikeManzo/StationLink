//
//  Friend.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct Friend: Identifiable, Codable {
    let id: String // Using onlineId as the primary identifier
    let accountId: String
    var user: PSNUser?
    var presence: PSNPresence?
    let addedDate: Date
    let isImported: Bool // Track if friend was imported from PSN vs manually added
    
    init(onlineId: String, accountId: String, user: PSNUser? = nil, presence: PSNPresence? = nil, isImported: Bool = false) {
        self.id = onlineId
        self.accountId = accountId
        self.user = user
        self.presence = presence
        self.addedDate = Date()
        self.isImported = isImported
    }
}

struct FriendSearchResult: Codable {
    let onlineId: String
    let accountId: String
    let avatarUrls: [PSNUser.AvatarUrl]?
}
