//
//  SettingsView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var psService: PlayStationService
    @StateObject private var appSettings = AppSettings.shared
    @State private var npssoToken = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            // General Tab
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            // Account Tab
            accountTab
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
            
            // Appearance Tab
            appearanceTab
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
        }
        .frame(width: 375, height: 450)
    }
    
    // MARK: - General Tab
    
    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Launch at Login", isOn: $appSettings.launchAtLogin)
                    
                    Text("Automatically start StationLink when you log in to your Mac")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(4)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
    
    // MARK: - Account Tab
    
    private var accountTab: some View {
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
            
            Spacer()
            
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
    }
    
    // MARK: - Appearance Tab
    
    private var appearanceTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Menubar Icon")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose the icon that appears in your menubar")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(IconSet.allCases) { iconSet in
                        IconSelectionCard(
                            iconSet: iconSet,
                            isSelected: appSettings.selectedIconSet == iconSet
                        ) {
                            appSettings.selectedIconSet = iconSet
                        }
                    }
                }
                .padding(.vertical)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
    }
}
// MARK: - Icon Selection Card

struct IconSelectionCard: View {
    let iconSet: IconSet
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon Preview
                Group {
                    if iconSet.isAssetCatalogImage {
                        // Show asset catalog image with original colors
                        if let nsImage = NSImage(named: iconSet.assetName) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        } else {
                            // Fallback if image not found - show placeholder with debug info
                            VStack(spacing: 2) {
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                Text("Not found")
                                    .font(.caption2)
                            }
                            .foregroundColor(.red.opacity(0.6))
                        }
                    } else {
                        // Show SF Symbol
                        Image(systemName: iconSet.symbolName)
                            .font(.system(size: 32))
                            .foregroundColor(isSelected ? .accentColor : .primary)
                    }
                }
                .frame(height: 36)
                
                VStack(spacing: 4) {
                    // Name
                    Text(iconSet.displayName)
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .multilineTextAlignment(.center)
                    
                    // Description
                    Text(iconSet.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

