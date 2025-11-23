//
//  AboutMeView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - About Me View
struct AboutMeView: View {
    let aboutMe: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "text.quote")
                    .foregroundColor(.secondary)
                    .font(.title3)
                Text("About Me")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(aboutMe)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.08))
                )
        }
        .padding(.horizontal, 16)
    }
}
