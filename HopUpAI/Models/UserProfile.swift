//
//  UserProfile.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData
import SwiftUI

/// User profile for gamification (level, XP, streaks)
@Model
final class UserProfile {
    // MARK: - Properties
    
    var id: UUID
    var displayName: String
    
    /// Current level (1-100)
    var level: Int
    
    /// XP in current level
    var currentXP: Int
    
    /// Total XP earned all time
    var totalXP: Int
    
    /// Current consecutive day streak
    var currentStreak: Int
    
    /// Longest streak achieved
    var longestStreak: Int
    
    /// Last workout completion date
    var lastWorkoutDate: Date?
    
    /// Total workouts completed
    var totalWorkoutsCompleted: Int
    
    /// Account creation date
    var createdAt: Date
    
    // MARK: - Initialization
    
    init(displayName: String = "Player") {
        self.id = UUID()
        self.displayName = displayName
        self.level = 1
        self.currentXP = 0
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastWorkoutDate = nil
        self.totalWorkoutsCompleted = 0
        self.createdAt = Date()
    }
}

// MARK: - Level System

extension UserProfile {
    /// XP required to reach the next level
    var xpToNextLevel: Int {
        XPService.xpRequired(for: level + 1)
    }
    
    /// Progress to next level (0.0 - 1.0)
    var levelProgress: Double {
        let required = xpToNextLevel
        guard required > 0 else { return 0 }
        return min(Double(currentXP) / Double(required), 1.0)
    }
    
    /// Title based on current level
    var levelTitle: LevelTitle {
        LevelTitle.forLevel(level)
    }
    
    /// Check if user should level up and do so
    @discardableResult
    func checkLevelUp() -> Bool {
        var didLevelUp = false
        while currentXP >= xpToNextLevel && level < 100 {
            currentXP -= xpToNextLevel
            level += 1
            didLevelUp = true
        }
        return didLevelUp
    }
    
    /// Add XP and check for level up
    func addXP(_ amount: Int) -> (xpGained: Int, didLevelUp: Bool, newLevel: Int?) {
        let previousLevel = level
        currentXP += amount
        totalXP += amount
        let didLevelUp = checkLevelUp()
        return (amount, didLevelUp, didLevelUp ? level : nil)
    }
}

// MARK: - Streak System

extension UserProfile {
    /// Update streak based on workout completion
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastWorkoutDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 0 {
                // Same day, no streak change
                return
            } else if daysDiff == 1 {
                // Consecutive day, increase streak
                currentStreak += 1
            } else {
                // Streak broken, reset
                currentStreak = 1
            }
        } else {
            // First workout
            currentStreak = 1
        }
        
        // Update longest streak
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        
        lastWorkoutDate = Date()
    }
    
    /// Calculate streak bonus multiplier
    var streakMultiplier: Double {
        // 10% bonus per consecutive day, max 50%
        return min(1.0 + (Double(currentStreak) * 0.1), 1.5)
    }
    
    /// Check if streak is at risk (no workout today)
    var isStreakAtRisk: Bool {
        guard let lastDate = lastWorkoutDate else { return false }
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastDate)
    }
}

// MARK: - Level Titles

enum LevelTitle: String, CaseIterable {
    case rookie = "Rookie"
    case jv = "JV Player"
    case varsity = "Varsity"
    case allStar = "All-Star"
    case allAmerican = "All-American"
    case pro = "Pro"
    case elite = "Elite"
    case mvp = "MVP"
    
    /// Get title for a given level
    static func forLevel(_ level: Int) -> LevelTitle {
        switch level {
        case 1...5: return .rookie
        case 6...15: return .jv
        case 16...30: return .varsity
        case 31...50: return .allStar
        case 51...75: return .allAmerican
        case 76...90: return .pro
        case 91...99: return .elite
        case 100: return .mvp
        default: return .rookie
        }
    }
    
    /// Color for this title
    var color: Color {
        switch self {
        case .rookie: return AppColors.levelRookie
        case .jv: return AppColors.levelJV
        case .varsity: return AppColors.levelVarsity
        case .allStar: return AppColors.levelAllStar
        case .allAmerican: return AppColors.levelAllAmerican
        case .pro: return AppColors.levelPro
        case .elite: return AppColors.levelElite
        case .mvp: return AppColors.levelMVP
        }
    }
    
    /// Icon for this title
    var icon: String {
        switch self {
        case .rookie: return "star"
        case .jv: return "star.fill"
        case .varsity: return "star.circle"
        case .allStar: return "star.circle.fill"
        case .allAmerican: return "flag.fill"
        case .pro: return "trophy"
        case .elite: return "trophy.fill"
        case .mvp: return "crown.fill"
        }
    }
}

// MARK: - Sample Data

extension UserProfile {
    static var sampleProfile: UserProfile {
        let profile = UserProfile(displayName: "Sarah")
        profile.level = 12
        profile.currentXP = 180
        profile.totalXP = 2450
        profile.currentStreak = 5
        profile.longestStreak = 12
        profile.lastWorkoutDate = Date()
        profile.totalWorkoutsCompleted = 28
        return profile
    }
}
