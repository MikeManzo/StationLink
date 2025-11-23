//
//  TrophySectionView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - Trophy Section View
struct TrophySectionView: View {
    let trophies: PSNUser.TrophySummary
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .font(.title3)
                
                Text("Trophy Level")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(trophies.level)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal, 16)
            
            if let progress = trophies.progress {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Progress to next level")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(progress)%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress) / 100)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 16)
            }
            
            if let earnedTrophies = trophies.earnedTrophies {
                VStack(spacing: 10) {
                    TrophyStatRow(
                        icon: "◆",
                        color: Color(red: 0.4, green: 0.8, blue: 1),
                        label: "Platinum",
                        count: earnedTrophies.platinum
                    )
                    TrophyStatRow(
                        icon: "◆",
                        color: Color(red: 1, green: 0.84, blue: 0),
                        label: "Gold",
                        count: earnedTrophies.gold
                    )
                    TrophyStatRow(
                        icon: "◆",
                        color: Color(red: 0.75, green: 0.75, blue: 0.75),
                        label: "Silver",
                        count: earnedTrophies.silver
                    )
                    TrophyStatRow(
                        icon: "◆",
                        color: Color(red: 0.8, green: 0.5, blue: 0.2),
                        label: "Bronze",
                        count: earnedTrophies.bronze
                    )
                }
                .padding(.horizontal, 16)
                
                let totalTrophies = earnedTrophies.platinum + earnedTrophies.gold +
                                  earnedTrophies.silver + earnedTrophies.bronze
                
                HStack {
                    Spacer()
                    Text("Total: \(totalTrophies)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
