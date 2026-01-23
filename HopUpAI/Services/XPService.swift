//
//  XPService.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation

/// Service for XP and level calculations
enum XPService {
    // MARK: - XP Constants
    
    /// XP per completed round
    static let xpPerRound: Int = 10
    
    /// Bonus XP for completing all sets of an exercise
    static let xpExerciseBonus: Int = 25
    
    /// Bonus XP for completing entire workout
    static let xpWorkoutBonus: Int = 100
    
    /// Maximum streak multiplier (50% bonus)
    static let maxStreakMultiplier: Double = 1.5
    
    /// Streak multiplier increase per day
    static let streakMultiplierPerDay: Double = 0.1
    
    // MARK: - Level Calculation
    
    /// Calculate XP required to reach a specific level
    /// Formula: XP = 100 * (level ^ 1.5)
    static func xpRequired(for level: Int) -> Int {
        guard level > 1 else { return 0 }
        return Int(100.0 * pow(Double(level), 1.5))
    }
    
    /// Calculate total XP needed from level 1 to target level
    static func totalXPToLevel(_ targetLevel: Int) -> Int {
        var total = 0
        for level in 2...targetLevel {
            total += xpRequired(for: level)
        }
        return total
    }
    
    /// Calculate level from total XP
    static func levelFromTotalXP(_ totalXP: Int) -> (level: Int, remainingXP: Int) {
        var level = 1
        var remainingXP = totalXP
        
        while level < 100 {
            let xpNeeded = xpRequired(for: level + 1)
            if remainingXP >= xpNeeded {
                remainingXP -= xpNeeded
                level += 1
            } else {
                break
            }
        }
        
        return (level, remainingXP)
    }
    
    // MARK: - XP Calculation
    
    /// Calculate XP for completing rounds
    static func xpForRounds(_ rounds: Int, streakMultiplier: Double = 1.0) -> Int {
        let baseXP = rounds * xpPerRound
        return Int(Double(baseXP) * streakMultiplier)
    }
    
    /// Calculate XP for completing an exercise (all sets)
    static func xpForExerciseCompletion(rounds: Int, streakMultiplier: Double = 1.0) -> Int {
        let roundXP = xpForRounds(rounds, streakMultiplier: streakMultiplier)
        let bonusXP = Int(Double(xpExerciseBonus) * streakMultiplier)
        return roundXP + bonusXP
    }
    
    /// Calculate XP for completing entire workout
    static func xpForWorkoutCompletion(
        exercises: Int,
        totalRounds: Int,
        streakDays: Int
    ) -> Int {
        let multiplier = streakMultiplier(for: streakDays)
        let roundXP = xpForRounds(totalRounds, streakMultiplier: multiplier)
        let exerciseBonus = Int(Double(exercises * xpExerciseBonus) * multiplier)
        let workoutBonus = Int(Double(xpWorkoutBonus) * multiplier)
        return roundXP + exerciseBonus + workoutBonus
    }
    
    /// Calculate streak multiplier
    static func streakMultiplier(for streakDays: Int) -> Double {
        let multiplier = 1.0 + (Double(streakDays) * streakMultiplierPerDay)
        return min(multiplier, maxStreakMultiplier)
    }
    
    // MARK: - Progress Helpers
    
    /// Calculate progress percentage to next level
    static func progressToNextLevel(currentXP: Int, level: Int) -> Double {
        let required = xpRequired(for: level + 1)
        guard required > 0 else { return 1.0 }
        return min(Double(currentXP) / Double(required), 1.0)
    }
    
    /// Format XP for display
    static func formatXP(_ xp: Int) -> String {
        if xp >= 1000 {
            let thousands = Double(xp) / 1000.0
            return String(format: "%.1fK", thousands)
        }
        return "\(xp)"
    }
    
    /// Format XP with label
    static func formatXPWithLabel(_ xp: Int) -> String {
        return "+\(formatXP(xp)) XP"
    }
}

// MARK: - Sample Calculations (for reference)

extension XPService {
    /// Sample level progression table
    static var levelProgressionTable: [(level: Int, xpRequired: Int, totalXP: Int)] {
        var table: [(Int, Int, Int)] = []
        var total = 0
        for level in 1...100 {
            let required = xpRequired(for: level)
            total += required
            table.append((level, required, total))
        }
        return table
    }
    
    /// Print level progression (for debugging)
    static func printLevelProgression() {
        print("Level Progression Table")
        print("-----------------------")
        for entry in levelProgressionTable.prefix(20) {
            print("Level \(entry.level): \(entry.xpRequired) XP (Total: \(entry.totalXP))")
        }
    }
}
