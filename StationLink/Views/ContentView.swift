//
//  ContentView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - Views
struct ContentView: View {
    @StateObject private var psService = PlayStationService()
    @State private var showingSettings = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("", selection: $selectedTab) {
                Text("Me").tag(0)
                Text("Games").tag(1)
                Text("Friends (\(psService.friends.count))").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // Content
            if psService.isLoading && psService.user == nil {
                ProgressView()
                    .padding()
                    .frame(width: 350)
            } else {
                if selectedTab == 0 {
                    if let user = psService.user {
                        UserInfoView(user: user, presence: psService.presence)
                            .frame(width: 350)
                    } else {
                        NoDataView(errorMessage: psService.errorMessage)
                            .frame(width: 350)
                    }
                } else if selectedTab == 1 {
                    GamesListView(psService: psService)
                        .frame(width: 350)
                } else {
                    FriendsListView(psService: psService)
                        .frame(width: 350)
                }
            }
            
            Divider()
            
            HStack {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Settings")
                
                Spacer()
                
                Button(action: {
                    Task {
                        await psService.refresh()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .disabled(psService.isLoading)
                .help("Refresh")
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Quit")
            }
            .padding(8)
        }
        .fixedSize()
        .onAppear {
            psService.loadStoredCredentials()
            Task {
                await psService.authenticate()
            }
        }
        .onDisappear {
            psService.stopAutoRefresh()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(psService: psService)
        }
    }
}

#Preview {
    ContentView()
}
