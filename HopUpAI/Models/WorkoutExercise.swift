//
//  WorkoutExercise.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData

/// Join table connecting exercises to workouts with custom overrides
@Model
final class WorkoutExercise {
    // MARK: - Properties
    
    var id: UUID
    
    /// Position in the workout order
    var sortOrder: Int
    
    /// Override values (nil means use exercise defaults)
    var sets: Int
    var reps: Int
    var weight: Double?
    var duration: Int?  // In seconds
    
    // MARK: - Relationships
    
    var exercise: Exercise?
    var workout: Workout?
    
    // MARK: - Initialization
    
    init(
        exercise: Exercise,
        workout: Workout,
        sortOrder: Int,
        sets: Int? = nil,
        reps: Int? = nil,
        weight: Double? = nil,
        duration: Int? = nil
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.workout = workout
        self.sortOrder = sortOrder
        
        // Use provided values or fall back to exercise defaults
        self.sets = sets ?? exercise.defaultSets
        self.reps = reps ?? exercise.defaultReps
        self.weight = weight ?? exercise.defaultWeight
        self.duration = duration ?? exercise.defaultDuration
    }
}

// MARK: - Display Helpers

extension WorkoutExercise {
    /// Configuration text for this workout exercise
    var configurationText: String {
        guard let exercise = exercise else { return "Unknown exercise" }
        
        switch exercise.type {
        case .weight:
            let weightText = weight.map { "\(Int($0)) lbs" } ?? "No weight"
            return "\(sets) × \(reps) @ \(weightText)"
        case .bodyweight:
            return "\(sets) × \(reps) reps"
        case .cardio:
            let durationText = duration.map { formatDuration($0) } ?? "No duration"
            return "\(sets) × \(durationText)"
        case .drill:
            return "\(sets) × \(reps) reps"
        }
    }
    
    /// Short configuration text
    var shortConfigText: String {
        guard let exercise = exercise else { return "" }
        
        switch exercise.type {
        case .weight:
            return "\(sets)×\(reps)"
        case .bodyweight, .drill:
            return "\(sets)×\(reps)"
        case .cardio:
            let mins = (duration ?? 0) / 60
            return "\(sets)×\(mins)m"
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds > 0 {
                return "\(minutes)m \(remainingSeconds)s"
            }
            return "\(minutes) min"
        }
        return "\(seconds)s"
    }
}
