//
//  TrophyBreakdownRow.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct TrophyBreakdownRow: View {
    let icon: String
    let color: Color
    let label: String
    let earned: Int
    let total: Int
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Text(icon)
                    .foregroundColor(color)
                    .font(.body)
                    .frame(width: 20)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("\(earned) / \(total)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(earned == total ? .green : .secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
        .background(color.opacity(0.08))
        .cornerRadius(8)
    }
}
