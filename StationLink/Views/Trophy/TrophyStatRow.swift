//
//  TrophyStatRow.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - Trophy Stat Row
struct TrophyStatRow: View {
    let icon: String
    let color: Color
    let label: String
    let count: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(icon)
                    .foregroundColor(color)
                    .font(.title3)
                    .frame(width: 24)
                
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
                .frame(minWidth: 40, alignment: .trailing)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(color.opacity(0.08))
        .cornerRadius(10)
    }
}
