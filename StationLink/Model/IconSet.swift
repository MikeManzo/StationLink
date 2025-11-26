//
//  IconSet.swift
//  StationLink
//
//  Created by Mike Manzo on 11/27/25.
//

import SwiftUI

/// Defines available menubar icon options
enum IconSet: String, CaseIterable, Identifiable {
    case playstation = "playstation.logo"
    case gamecontroller = "gamecontroller.fill"
    case playCircle = "play.circle.fill"
    case circleSquare = "circle.square"
    case controller = "l.joystick.press.down.fill"
    case trophy = "trophy.fill"
    case star = "star.fill"
    case appIcon = "AppIcon"
    case appIconBW = "AppIcon_BW"
    case appIconWB = "AppIcon_WB"
    
    var id: String { rawValue }
    
    /// User-friendly display name
    var displayName: String {
        switch self {
        case .playstation:
            return "PlayStation Logo"
        case .gamecontroller:
            return "Game Controller"
        case .playCircle:
            return "Play Circle"
        case .circleSquare:
            return "Circle & Square"
        case .controller:
            return "Joystick"
        case .trophy:
            return "Trophy"
        case .star:
            return "Star"
        case .appIcon:
            return "App Icon"
        case .appIconBW:
            return "App Icon (B&W)"
        case .appIconWB:
            return "App Icon (W&B)"
        }
    }
    
    /// Description for each icon option
    var description: String {
        switch self {
        case .playstation:
            return "Classic PlayStation logo"
        case .gamecontroller:
            return "Filled game controller icon"
        case .playCircle:
            return "Play button in a circle"
        case .circleSquare:
            return "PlayStation button symbols"
        case .controller:
            return "Joystick press icon"
        case .trophy:
            return "Trophy achievement icon"
        case .star:
            return "Star icon"
        case .appIcon:
            return "Default app icon"
        case .appIconBW:
            return "Black & White variant"
        case .appIconWB:
            return "White & Black variant"
        }
    }
    
    /// Whether this icon is from the asset catalog (true) or SF Symbols (false)
    var isAssetCatalogImage: Bool {
        switch self {
        case .appIcon, .appIconBW, .appIconWB:
            return true
        default:
            return false
        }
    }
    
    /// SF Symbol name for the icon (only for SF Symbol icons)
    var symbolName: String {
        rawValue
    }
    
    /// Asset name for asset catalog images, may differ from rawValue
    var assetName: String {
        switch self {
        case .appIcon:
            return "AppIcon"
        case .appIconBW:
            return "AppIcon_BW"
        case .appIconWB:
            return "AppIcon_WB"
        default:
            return rawValue
        }
    }
}
