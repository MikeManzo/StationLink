//
//  AppSettings.swift
//  StationLink
//
//  Created by Mike Manzo on 11/27/25.
//

import SwiftUI
import Combine

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
    
    private let iconSetKey = "selectedMenubarIcon"
    
    private init() {
        // Load saved icon set or default to PlayStation logo
        if let savedRawValue = UserDefaults.standard.string(forKey: iconSetKey),
           let savedIconSet = IconSet(rawValue: savedRawValue) {
            self.selectedIconSet = savedIconSet
        } else {
            self.selectedIconSet = .playstation
        }
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
}
