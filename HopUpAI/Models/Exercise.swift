//
//  Exercise.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData

/// An exercise that can be added to workouts
@Model
final class Exercise {
    // MARK: - Properties
    
    var id: UUID
    var name: String
    var exerciseDescription: String?
    
    /// Stored as raw string for SwiftData compatibility
    private var typeRawValue: String
    
    var defaultSets: Int
    var defaultReps: Int
    var defaultWeight: Double?
    var defaultDuration: Int?  // In seconds
    
    var createdAt: Date
    
    // MARK: - Relationships
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.exercise)
    var workoutExercises: [WorkoutExercise]?
    
    // MARK: - Computed Properties
    
    var type: ExerciseType {
        get { ExerciseType(rawValue: typeRawValue) ?? .bodyweight }
        set { typeRawValue = newValue.rawValue }
    }
    
    // MARK: - Initialization
    
    init(
        name: String,
        exerciseDescription: String? = nil,
        type: ExerciseType = .bodyweight,
        defaultSets: Int = 3,
        defaultReps: Int = 10,
        defaultWeight: Double? = nil,
        defaultDuration: Int? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.exerciseDescription = exerciseDescription
        self.typeRawValue = type.rawValue
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultWeight = defaultWeight
        self.defaultDuration = defaultDuration
        self.createdAt = Date()
    }
}

// MARK: - Display Helpers

extension Exercise {
    /// Formatted default configuration string
    var defaultConfigurationText: String {
        switch type {
        case .weight:
            let weightText = defaultWeight.map { "\(Int($0)) lbs" } ?? "No weight"
            return "\(defaultSets) sets × \(defaultReps) reps @ \(weightText)"
        case .bodyweight:
            return "\(defaultSets) sets × \(defaultReps) reps"
        case .cardio:
            let durationText = defaultDuration.map { formatDuration($0) } ?? "No duration"
            return "\(defaultSets) rounds × \(durationText)"
        case .drill:
            return "\(defaultSets) sets × \(defaultReps) reps"
        }
    }
    
    /// Format seconds into readable duration
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

// MARK: - Sample Data

extension Exercise {
    static var sampleExercises: [Exercise] {
        [
            Exercise(
                name: "Free Throws",
                exerciseDescription: "Practice free throw shooting form and consistency",
                type: .drill,
                defaultSets: 5,
                defaultReps: 10
            ),
            Exercise(
                name: "Layup Drills",
                exerciseDescription: "Alternating left and right hand layups",
                type: .drill,
                defaultSets: 3,
                defaultReps: 20
            ),
            Exercise(
                name: "Dribble Suicides",
                exerciseDescription: "Sprint suicides while dribbling",
                type: .cardio,
                defaultSets: 4,
                defaultDuration: 60
            ),
            Exercise(
                name: "Squats",
                exerciseDescription: "Barbell back squats for leg strength",
                type: .weight,
                defaultSets: 4,
                defaultReps: 8,
                defaultWeight: 95
            ),
            Exercise(
                name: "Push-ups",
                exerciseDescription: "Standard push-ups for upper body strength",
                type: .bodyweight,
                defaultSets: 3,
                defaultReps: 15
            ),
            Exercise(
                name: "Box Jumps",
                exerciseDescription: "Explosive box jumps for vertical leap",
                type: .bodyweight,
                defaultSets: 4,
                defaultReps: 10
            ),
            Exercise(
                name: "Defensive Slides",
                exerciseDescription: "Lateral defensive sliding drills",
                type: .drill,
                defaultSets: 4,
                defaultReps: 20
            ),
            Exercise(
                name: "Three-Point Shooting",
                exerciseDescription: "Practice three-point shots from various spots",
                type: .drill,
                defaultSets: 5,
                defaultReps: 10
            )
        ]
    }
}
