//
//  GameRowView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct GameRowView: View {
    let game: GameTitle
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 12) {
                // Game Image
                if let imageUrl = game.imageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "gamecontroller")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    if let platform = game.platform {
                        Text(platform)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastPlayed = game.lastPlayedDateTime {
                        Text(formatDate(lastPlayed))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    // Trophy progress bar
                    if game.completionPercentage > 0 {
                        HStack(spacing: 6) {
                            ProgressView(value: Double(game.completionPercentage), total: 100)
                                .tint(.yellow)
                                .frame(height: 6)
                            
                            Text("\(game.completionPercentage)%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .trailing)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            GameDetailView(game: game)
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return "Recently"
            }
            return formatRelativeDate(date)
        }
        
        return formatRelativeDate(date)
    }
    
    func formatRelativeDate(_ date: Date) -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m ago"
        }
        
        if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)h ago"
        }
        
        if timeInterval < 604800 {
            let days = Int(timeInterval / 86400)
            return "\(days)d ago"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        return displayFormatter.string(from: date)
    }
}
