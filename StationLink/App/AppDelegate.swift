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
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "playstation.logo", accessibilityDescription: "PlayStation")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
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
}
