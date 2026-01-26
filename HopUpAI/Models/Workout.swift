//
//  Workout.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData

/// A workout containing multiple exercises
@Model
final class Workout {
    // MARK: - Properties
    
    var id: UUID
    var name: String
    var workoutDescription: String?
    var createdAt: Date
    var updatedAt: Date = Date()
    var needsSync: Bool = false
    
    // MARK: - Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise]?
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSession.workout)
    var sessions: [WorkoutSession]?
    
    // MARK: - Initialization
    
    init(
        name: String,
        workoutDescription: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.workoutDescription = workoutDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.needsSync = false
    }
}

// MARK: - Display Helpers

extension Workout {
    /// Formatted exercise count text
    var exerciseCountText: String {
        let count = exerciseCount
        return count == 1 ? "1 exercise" : "\(count) exercises"
    }
    
    /// Formatted duration text
    var durationText: String {
        let mins = estimatedDuration
        if mins >= 60 {
            let hours = mins / 60
            let remainingMins = mins % 60
            if remainingMins > 0 {
                return "\(hours)h \(remainingMins)m"
            }
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
        return "\(mins) min"
    }
    
    /// Total number of exercises in this workout
    var exerciseCount: Int {
        exercises?.count ?? 0
    }
    
    /// Estimated duration in minutes (rough estimate)
    var estimatedDuration: Int {
        let totalSets = sortedExercises.reduce(0) { $0 + $1.sets }
        // Assume ~2 minutes per set including rest
        return max(totalSets * 2, 5)
    }
    
    /// Number of times this workout has been completed
    var completionCount: Int {
        sessions?.filter { $0.completedAt != nil }.count ?? 0
    }
    
    /// Last time this workout was completed
    var lastCompletedAt: Date? {
        sessions?
            .filter { $0.completedAt != nil }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
            .first?.completedAt
    }
    
    /// Get exercises sorted by their order
    var sortedExercises: [WorkoutExercise] {
        (exercises ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }
    
    /// Summary of exercise types in this workout
    var exerciseTypeSummary: [ExerciseType: Int] {
        var summary: [ExerciseType: Int] = [:]
        for workoutExercise in sortedExercises {
            let type = workoutExercise.exercise?.type ?? .bodyweight
            summary[type, default: 0] += 1
        }
        return summary
    }
}

// MARK: - Sample Data

extension Workout {
    static func sampleWorkout(with exercises: [Exercise]) -> Workout {
        let workout = Workout(
            name: "Pre-Game Warmup",
            workoutDescription: "Complete warmup routine before games"
        )
        // Note: WorkoutExercises would need to be created separately
        return workout
    }
    
    static var sampleWorkoutNames: [(name: String, description: String)] {
        [
            ("Pre-Game Warmup", "Complete warmup routine before games"),
            ("Shooting Practice", "Focus on shooting form and accuracy"),
            ("Leg Day", "Lower body strength training"),
            ("Full Court Conditioning", "Endurance and cardio workout"),
            ("Ball Handling", "Dribbling and ball control drills"),
            ("Game Day Prep", "Light workout to stay loose before games")
        ]
    }
}