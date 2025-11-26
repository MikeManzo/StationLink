//
//  AppDelegate.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI
import AppKit
import UserNotifications


class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - make this a pure menubar app
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✓ Notification permission granted")
            } else if let error = error {
                print("⚠ Notification permission error: \(error.localizedDescription)")
            }
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set initial icon from saved settings
        updateMenubarIcon()
        
        if let button = statusItem?.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Listen for icon change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleIconChange),
            name: NSNotification.Name("MenubarIconChanged"),
            object: nil
        )
        
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.behavior = .transient
    }
    
    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc private func handleIconChange(_ notification: Notification) {
        updateMenubarIcon()
    }
    
    @MainActor
    private func updateMenubarIcon() {
        let selectedIcon = AppSettings.shared.selectedIconSet
        
        if let button = statusItem?.button {
            let image: NSImage?
            
            if selectedIcon.isAssetCatalogImage {
                // Load from asset catalog
                image = NSImage(named: selectedIcon.assetName)
            } else {
                // Load SF Symbol
                image = NSImage(
                    systemSymbolName: selectedIcon.symbolName,
                    accessibilityDescription: selectedIcon.displayName
                )
            }
            
            // Set the image and configure it for menubar display
            if let image = image {
                // Resize image to fit menubar (typically 18x18 or 22x22 points)
                image.size = NSSize(width: 18, height: 18)
                
                // Only use template mode for SF Symbols, not for custom asset images
                // This preserves the original colors of your custom icons
                image.isTemplate = !selectedIcon.isAssetCatalogImage
                
                button.image = image
            }
        }
    }
}
