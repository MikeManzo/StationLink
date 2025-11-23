//
//  GameDetailView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct GameDetailView: View {
    let game: GameTitle
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Game Details")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Game Image
                    if let imageUrl = game.imageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(12)
                    }
                    
                    // Game Title
                    Text(game.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Platform
                    if let platform = game.platform {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                                .foregroundColor(.blue)
                            Text(platform)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Trophy Progress
                    if let earned = game.earnedTrophies, let defined = game.definedTrophies {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trophy Progress")
                                .font(.headline)
                            
                            // Progress bar
                            VStack(spacing: 6) {
                                HStack {
                                    Text("\(game.completionPercentage)% Complete")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    let total = earned.bronze + earned.silver + earned.gold + earned.platinum
                                    let totalDefined = defined.bronze + defined.silver + defined.gold + defined.platinum
                                    Text("\(total) / \(totalDefined)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.2))
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.yellow, Color.orange],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * CGFloat(game.completionPercentage) / 100)
                                    }
                                }
                                .frame(height: 10)
                            }
                            
                            // Trophy breakdown
                            VStack(spacing: 10) {
                                TrophyBreakdownRow(icon: "◆", color: .cyan, label: "Platinum", earned: earned.platinum, total: defined.platinum)
                                TrophyBreakdownRow(icon: "◆", color: .yellow, label: "Gold", earned: earned.gold, total: defined.gold)
                                TrophyBreakdownRow(icon: "◆", color: .gray, label: "Silver", earned: earned.silver, total: defined.silver)
                                TrophyBreakdownRow(icon: "◆", color: .orange, label: "Bronze", earned: earned.bronze, total: defined.bronze)
                            }
                        }
                        
                        Divider()
                    }
                    
                    // Play time
                    if let playDuration = game.playDuration {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Play Time")
                                .font(.headline)
                            
                            Text(playDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                    }
                    
                    // Last played
                    if let lastPlayed = game.lastPlayedDateTime {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Played")
                                .font(.headline)
                            
                            Text(formatDate(lastPlayed))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 400)
        .fixedSize()
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = formatter.date(from: dateString) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateString) else {
                return dateString
            }
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .long
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .long
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
