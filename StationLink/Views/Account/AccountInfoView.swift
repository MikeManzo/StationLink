//
//  AccountInfoView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - Account Info View
struct AccountInfoView: View {
    let accountId: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.secondary)
                    .font(.title3)
                Text("Account Info")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack {
                Text("Account ID:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(accountId)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.08))
            )
        }
        .padding(.horizontal, 16)
    }
}
