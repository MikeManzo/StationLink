//
//  UserInfoView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct UserInfoView: View {
    let user: PSNUser
    let presence: PSNPresence?
    
    var body: some View {
        VStack(spacing: 0) {
            // Hero header with gradient background
            ZStack(alignment: .bottom) {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0, green: 0.22, blue: 0.57), Color(red: 0, green: 0.44, blue: 0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 140)
                
                // Avatar and basic info
                HStack(spacing: 16) {
                    // Avatar with glow effect
                    ZStack {
                        if let avatarUrl = user.avatarUrl,
                           let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)
                                        .font(.title)
                                )
                        }
                        
                        // Status indicator with pulse animation
                        if let presence = presence {
                            Circle()
                                .fill(statusColor(presence.onlineStatus))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2.5)
                                )
                                .offset(x: 28, y: 28)
                                .shadow(color: .black.opacity(0.3), radius: 3)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.onlineId)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                        
                        if let presence = presence {
                            HStack(spacing: 6) {
                                Text(presence.onlineStatus.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                if let platform = presence.platform {
                                    HStack(spacing: 4) {
                                        Image(systemName: platformIcon(platform))
                                            .font(.caption)
                                        Text(platform)
                                            .font(.caption)
                                    }
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // Content sections
            ScrollView {
                VStack(spacing: 0) {
                    // Trophy Section
                    if let trophies = user.trophySummary {
                        TrophySectionView(trophies: trophies)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    
                    // Currently Playing Section
                    if let gameInfo = presence?.gameTitleInfo,
                       let gameName = gameInfo.titleName {
                        NowPlayingView(gameName: gameName, titleId: gameInfo.npTitleId)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    
                    // Last Online Section
                    if let presence = presence,
                       let lastOnline = presence.primaryPlatformInfo?.lastOnlineDate {
                        LastOnlineView(lastOnline: lastOnline)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    
                    // About Me Section
                    if let aboutMe = user.aboutMe, !aboutMe.isEmpty {
                        AboutMeView(aboutMe: aboutMe)
                            .padding(.vertical, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                    }
                    
                    // Account Info Section
                    AccountInfoView(accountId: user.accountId)
                        .padding(.vertical, 16)
                }
            }
        }
        .padding(0)
    }
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "online": return Color(red: 0, green: 0.84, blue: 0.37)
        case "away": return Color(red: 1, green: 0.8, blue: 0)
        case "busy": return Color(red: 1, green: 0.27, blue: 0.23)
        default: return Color.gray
        }
    }
    
    func platformIcon(_ platform: String) -> String {
        switch platform.uppercased() {
        case "PS5": return "play.rectangle.fill"
        case "PS4": return "play.rectangle"
        case "PS3": return "play.circle"
        case "PSVITA": return "play.circle.fill"
        default: return "gamecontroller"
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return "Just now"
        }
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        
        if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        }
        
        if timeInterval < 604800 {
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
