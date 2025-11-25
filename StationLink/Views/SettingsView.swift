//
//  SettingsView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var psService: PlayStationService
    @State private var npssoToken = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PlayStation Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Get your NPSSO token:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("1. Log in to playstation.com\n2. Visit: ca.account.sony.com/api/v1/ssocookie\n3. Copy the 64-character token")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("NPSSO Token:")
                    .font(.subheadline)
                
                SecureField("Paste your NPSSO token here", text: $npssoToken)
                    .textFieldStyle(.roundedBorder)
                
                Text("Token is cached for ~2 months after first use")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Spacer()
                
                Button("Save & Connect") {
                    psService.setNPSSO(npssoToken)
                    dismiss()
                    Task {
                        await psService.authenticate()
                    }
                }
                .disabled(npssoToken.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}
