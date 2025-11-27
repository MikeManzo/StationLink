//
//  AppSettings.swift
//  StationLink
//
//  Created by Mike Manzo on 11/27/25.
//

import SwiftUI
import Combine
import ServiceManagement

/// Manages app-wide settings and preferences
@MainActor
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var selectedIconSet: IconSet {
        didSet {
            saveIconSet()
            notifyIconChange()
        }
    }
    
    @Published var launchAtLogin: Bool {
        didSet {
            setLoginItemEnabled(launchAtLogin)
        }
    }
    
    private let iconSetKey = "selectedMenubarIcon"
    
    private init() {
        // Load saved icon set or default to PlayStation logo
        if let savedRawValue = UserDefaults.standard.string(forKey: iconSetKey),
           let savedIconSet = IconSet(rawValue: savedRawValue) {
            self.selectedIconSet = savedIconSet
        } else {
            self.selectedIconSet = .playstation
        }
        
        // Load login item status
        self.launchAtLogin = SMAppService.mainApp.status == .enabled
    }
    
    private func saveIconSet() {
        UserDefaults.standard.set(selectedIconSet.rawValue, forKey: iconSetKey)
    }
    
    private func notifyIconChange() {
        NotificationCenter.default.post(
            name: NSNotification.Name("MenubarIconChanged"),
            object: nil,
            userInfo: ["iconSet": selectedIconSet]
        )
    }
    
    // MARK: - Login Item Management
    
    /// Enables or disables the app as a login item
    private func setLoginItemEnabled(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    print("✓ App is already a login item")
                } else {
                    try SMAppService.mainApp.register()
                    print("✓ App registered as login item")
                }
            } else {
                try SMAppService.mainApp.unregister()
                print("✓ App unregistered as login item")
            }
        } catch {
            print("⚠ Failed to \(enabled ? "register" : "unregister") login item: \(error.localizedDescription)")
            // Revert the published property to reflect actual state
            Task { @MainActor in
                self.launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }
}
