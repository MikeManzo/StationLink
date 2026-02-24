//
//  TrophyDetailRow.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct TrophyDetailRow: View {
    let trophy: Trophy
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Trophy Icon
            AsyncImage(url: URL(string: trophy.trophyIconUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "trophy.fill")
                    .foregroundColor(trophy.trophyColor)
            }
            .frame(width: 48, height: 48)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Trophy Name
                HStack(spacing: 6) {
                    Text(trophy.trophyName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Trophy Type Badge
                    Text(trophy.trophyType.capitalized)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(trophy.trophyColor)
                        .cornerRadius(4)
                }
                
                // Trophy Description
                if !trophy.hidden || trophy.earned {
                    Text(trophy.trophyDetail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Hidden Trophy")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                }
                
                // Earned Status
                if let earnedDate = trophy.earnedDateTime {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text("Earned: \(formatDate(earnedDate))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 2)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Text("Not earned")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(trophy.earned ? Color.green.opacity(0.05) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(trophy.earned ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
        )
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
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
