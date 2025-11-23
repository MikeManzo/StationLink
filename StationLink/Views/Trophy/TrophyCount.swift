//
//  TrophyCount.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct TrophyCount: View {
    let count: Int
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .foregroundColor(color)
                .fontWeight(.bold)
            Text("\(count)")
                .foregroundColor(.primary)
        }
    }
}
