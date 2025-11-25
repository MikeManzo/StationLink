//
//  AboutTabView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/26/25.
//

import SwiftUI

struct AboutTabView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Header
                VStack(spacing: 8) {
                    Image(systemName: "playstation.logo")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("StationLink")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Made with ❤️ for PlayStation gamers on Mac")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                Divider()
                
                // Credits Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Credits & Acknowledgments")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        CreditRow(
                            title: "PSN API Documentation",
                            subtitle: "andshrew/PlayStation-Trophies",
                            icon: "book.fill",
                            url: "https://github.com/andshrew/PlayStation-Trophies"
                        )
                        
                        CreditRow(
                            title: "psn-api npm package",
                            subtitle: "achievements-app/psn-api",
                            icon: "cube.box.fill",
                            url: "https://github.com/achievements-app/psn-api"
                        )
                        
                        CreditRow(
                            title: "PSNAWP Python Library",
                            subtitle: "isFakeAccount/psnawp",
                            icon: "terminal.fill",
                            url: "https://github.com/isFakeAccount/psnawp"
                        )
                        
                        CreditRow(
                            title: "PSN API Community",
                            subtitle: "Reverse engineering & documentation",
                            icon: "person.3.fill",
                            url: nil
                        )
                    }
                }
                
                Divider()
                
                // Legal / Disclaimer Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Legal & Trademarks")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("This is an unofficial application and is not affiliated with, endorsed by, or associated with Sony Interactive Entertainment Inc.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Text("The following are trademarks or registered trademarks of Sony Interactive Entertainment Inc.:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            BulletPoint(text: "PlayStation®")
                            BulletPoint(text: "PlayStation Network™")
                            BulletPoint(text: "PS5™")
                            BulletPoint(text: "PS4™")
                            BulletPoint(text: "PlayStation logo and related marks")
                        }
                        .padding(.leading, 16)
                        
                        Text("All product names, logos, brands, trademarks and registered trademarks are property of their respective owners. All company, product and service names used in this application are for identification purposes only. Use of these names, trademarks and brands does not imply endorsement.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 6)
                    }
                }
                
                Divider()
                
                // License Section
                VStack(alignment: .leading, spacing: 6) {
                    Text("License")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("This software is provided for personal, non-commercial use only. This software is provided \"as is\" without warranty of any kind. Use at your own risk.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Copyright
                Text("© 2025 Mike Manzo - AKA CitizenCoder. All rights reserved.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Supporting Views

struct CreditRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let url: String?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let url = url {
                    Link(subtitle, destination: URL(string: url)!)
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
