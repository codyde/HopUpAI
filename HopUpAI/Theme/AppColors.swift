//
//  AppColors.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Basketball-inspired color palette for HopUpAI
enum AppColors {
    // MARK: - Backgrounds
    
    /// Main app background - deep dark
    static let background = Color(hex: "0F0F0F")
    
    /// Surface color - warm wood court tone
    static let court = Color(hex: "1A1510")
    
    /// Elevated surface
    static let courtElevated = Color(hex: "221C15")
    
    /// Court lines / borders
    static let courtLines = Color(hex: "2D2520")
    
    /// Hover/pressed state
    static let courtHover = Color(hex: "2A231B")
    
    // MARK: - Primary Colors
    
    /// Basketball orange - primary accent
    static let basketball = Color(hex: "F47C20")
    
    /// Basketball orange lighter variant
    static let basketballLight = Color(hex: "FF9642")
    
    /// Basketball orange darker variant
    static let basketballDark = Color(hex: "D66A15")
    
    /// Net white - secondary accent
    static let net = Color.white
    
    // MARK: - Gamification Colors
    
    /// Fire/streak color
    static let fire = Color(hex: "FF4444")
    
    /// Fire glow
    static let fireGlow = Color(hex: "FF6B35")
    
    /// Gold for achievements/level up
    static let gold = Color(hex: "FFD700")
    
    /// Gold glow
    static let goldGlow = Color(hex: "FFA500")
    
    /// XP bar gradient start
    static let xpStart = Color(hex: "F47C20")
    
    /// XP bar gradient end
    static let xpEnd = Color(hex: "FFD700")
    
    // MARK: - Text Colors
    
    /// Primary text - white
    static let textPrimary = Color.white
    
    /// Secondary text - muted
    static let textSecondary = Color(hex: "9A9A9A")
    
    /// Tertiary text - very muted
    static let textTertiary = Color(hex: "5C5C5C")
    
    // MARK: - Exercise Type Colors
    
    /// Weight training
    static let typeWeight = Color(hex: "8B5CF6")  // Purple
    
    /// Bodyweight exercises
    static let typeBodyweight = Color(hex: "06B6D4")  // Cyan
    
    /// Cardio
    static let typeCardio = Color(hex: "EF4444")  // Red
    
    /// Basketball drills
    static let typeDrill = Color(hex: "F47C20")  // Basketball orange
    
    // MARK: - Status Colors
    
    /// Success / completed
    static let success = Color(hex: "22C55E")
    
    /// Warning
    static let warning = Color(hex: "F59E0B")
    
    /// Error
    static let error = Color(hex: "EF4444")
    
    // MARK: - Level Title Colors
    
    static let levelRookie = Color(hex: "9CA3AF")      // Gray
    static let levelJV = Color(hex: "60A5FA")          // Blue
    static let levelVarsity = Color(hex: "34D399")     // Green
    static let levelAllStar = Color(hex: "A78BFA")     // Purple
    static let levelAllAmerican = Color(hex: "F472B6") // Pink
    static let levelPro = Color(hex: "FB923C")         // Orange
    static let levelElite = Color(hex: "FBBF24")       // Amber
    static let levelMVP = Color(hex: "FFD700")         // Gold
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Definitions

extension AppColors {
    /// XP progress bar gradient
    static var xpGradient: LinearGradient {
        LinearGradient(
            colors: [xpStart, xpEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    /// Fire/streak gradient
    static var fireGradient: LinearGradient {
        LinearGradient(
            colors: [fire, fireGlow],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    /// Gold achievement gradient
    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldGlow, gold],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    /// Basketball gradient for buttons
    static var basketballGradient: LinearGradient {
        LinearGradient(
            colors: [basketballDark, basketball, basketballLight],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}
