//
//  AddFriendView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct AddFriendView: View {
    @ObservedObject var psService: PlayStationService
    @State private var username = ""
    @State private var isSearching = false
    @State private var searchResult: FriendSearchResult?
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Friend")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("PSN Username:")
                    .font(.subheadline)
                
                TextField("Enter PlayStation Network ID", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        Task {
                            await searchUser()
                        }
                    }
            }
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            if isSearching {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let result = searchResult {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    Text("User Found:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        if let avatarUrl = result.avatarUrls?.first(where: { $0.size == "l" })?.avatarUrl.replacingOccurrences(of: "http://", with: "https://"),
                           let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        }
                        
                        Text(result.onlineId)
                            .font(.headline)
                    }
                    
                    Button("Add This Friend") {
                        Task {
                            await psService.addFriend(onlineId: result.onlineId, accountId: result.accountId)
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Search") {
                    Task {
                        await searchUser()
                    }
                }
                .disabled(username.isEmpty || isSearching)
            }
        }
        .padding()
        .frame(width: 400)
    }
    
    func searchUser() async {
        isSearching = true
        errorMessage = nil
        searchResult = nil
        
        if let result = await psService.searchUser(username: username) {
            await MainActor.run {
                searchResult = result
                isSearching = false
            }
        } else {
            await MainActor.run {
                errorMessage = "User '\(username)' not found"
                isSearching = false
            }
        }
    }
}
