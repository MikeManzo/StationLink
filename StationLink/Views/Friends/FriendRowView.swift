//
//  FriendRowView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct FriendRowView: View {
    let friend: Friend
    let onRemove: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatarUrl = friend.user?.avatarUrl,
               let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.user?.onlineId ?? friend.id)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let presence = friend.presence {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor(presence.onlineStatus))
                            .frame(width: 8, height: 8)
                        Text(presence.onlineStatus.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let platform = presence.platform {
                            Text("• \(platform)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("Status unknown")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let game = friend.presence?.gameTitleInfo?.titleName {
                    Text(game)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Menu {
                Button("View Details") {
                    showingDetail = true
                }
                
                Button("Remove", role: .destructive) {
                    onRemove()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.secondary)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .sheet(isPresented: $showingDetail) {
            if let user = friend.user {
                VStack(spacing: 0) {
                    HStack {
                        Text("Friend Details")
                            .font(.headline)
                        Spacer()
                        Button("Done") {
                            showingDetail = false
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    UserInfoView(user: user, presence: friend.presence)
                        .frame(width: 350)
                }
                .fixedSize()
            }
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "online": return .green
        case "away": return .yellow
        case "busy": return .red
        default: return .gray
        }
    }
}
