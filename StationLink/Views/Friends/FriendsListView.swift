//
//  FriendsListView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct FriendsListView: View {
    @ObservedObject var psService: PlayStationService
    @State private var showingAddFriend = false
    @State private var showImportedOnly = false
    
    var filteredFriends: [Friend] {
        showImportedOnly ? psService.friends.filter { $0.isImported } : psService.friends
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if psService.friends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No Friends Added")
                        .font(.headline)
                    Text("Friends will be imported from your PSN account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Add Friend Manually") {
                        showingAddFriend = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Filter toggle
                    HStack {
                        Toggle("PSN Friends Only", isOn: $showImportedOnly)
                            .toggleStyle(.switch)
                            .font(.caption)
                        
                        Spacer()
                        
                        Button(action: { showingAddFriend = true }) {
                            Image(systemName: "person.badge.plus")
                                .font(.title3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                    
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredFriends) { friend in
                                FriendRowView(friend: friend, onRemove: {
                                    psService.removeFriend(friend.id)
                                })
                                
                                if friend.id != filteredFriends.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
            }
        }
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView(psService: psService)
        }
    }
}
