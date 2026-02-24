//
//  GamesListView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/24/25.
//

import SwiftUI

struct GamesListView: View {
    @ObservedObject var psService: PlayStationService
    
    var body: some View {
        VStack(spacing: 0) {
            if psService.recentGames.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No Recent Games")
                        .font(.headline)
                    Text("Your recently played games will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(psService.recentGames) { game in
                            GameRowView(game: game)
                                .environmentObject(psService)
                            
                            if game.id != psService.recentGames.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 500)
            }
        }
    }
}
