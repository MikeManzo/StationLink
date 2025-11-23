//
//  StationLinkApp.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - App Entry Point
@main
struct PlayStationMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
