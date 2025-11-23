//
//  NowPlayingView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

/// MARK: - Now Playing View
struct NowPlayingView: View {
    let gameName: String
    let titleId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("Now Playing")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(gameName)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let titleId = titleId {
                    Text(titleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
            )
        }
        .padding(.horizontal, 16)
    }
}
