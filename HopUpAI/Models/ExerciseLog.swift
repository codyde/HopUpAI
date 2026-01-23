//
//  ExerciseLog.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData

/// A recorded instance of completing an exercise within a workout session
@Model
final class ExerciseLog {
    // MARK: - Properties
    
    var id: UUID
    
    /// Number of rounds/sets completed
    var roundsCompleted: Int
    
    /// Target rounds for this exercise
    var targetRounds: Int
    
    /// Reps completed per round (stored as JSON string for SwiftData)
    private var repsPerRoundJSON: String
    
    /// Weight used (if applicable)
    var weightUsed: Double?
    
    /// Duration in seconds (if applicable, for cardio)
    var durationCompleted: Int?
    
    /// XP earned for this exercise
    var xpEarned: Int
    
    /// Timestamp when this exercise was completed
    var completedAt: Date?
    
    // MARK: - Relationships
    
    var session: WorkoutSession?
    var exercise: Exercise?
    
    // MARK: - Computed Properties
    
    /// Reps per round as array
    var repsPerRound: [Int] {
        get {
            guard let data = repsPerRoundJSON.data(using: .utf8),
                  let array = try? JSONDecoder().decode([Int].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                repsPerRoundJSON = string
            }
        }
    }
    
    /// Total reps completed
    var totalReps: Int {
        repsPerRound.reduce(0, +)
    }
    
    /// Whether this exercise has been completed
    var isCompleted: Bool {
        completedAt != nil
    }
    
    /// Progress percentage (0.0 - 1.0)
    var progress: Double {
        guard targetRounds > 0 else { return 0 }
        return min(Double(roundsCompleted) / Double(targetRounds), 1.0)
    }
    
    // MARK: - Initialization
    
    init(
        exercise: Exercise,
        session: WorkoutSession,
        targetRounds: Int,
        weightUsed: Double? = nil
    ) {
        self.id = UUID()
        self.exercise = exercise
        self.session = session
        self.targetRounds = targetRounds
        self.roundsCompleted = 0
        self.repsPerRoundJSON = "[]"
        self.weightUsed = weightUsed
        self.durationCompleted = nil
        self.xpEarned = 0
        self.completedAt = nil
    }
}

// MARK: - Logging Methods

extension ExerciseLog {
    /// Log a completed round
    func logRound(reps: Int) {
        roundsCompleted += 1
        var currentReps = repsPerRound
        currentReps.append(reps)
        repsPerRound = currentReps
    }
    
    /// Log duration (for cardio exercises)
    func logDuration(_ seconds: Int) {
        durationCompleted = (durationCompleted ?? 0) + seconds
        roundsCompleted += 1
    }
    
    /// Mark exercise as completed
    func complete() {
        completedAt = Date()
    }
    
    /// Add XP earned
    func addXP(_ amount: Int) {
        xpEarned += amount
    }
}

// MARK: - Display Helpers

extension ExerciseLog {
    /// Progress text
    var progressText: String {
        "\(roundsCompleted)/\(targetRounds) rounds"
    }
    
    /// Summary text for completed exercise
    var summaryText: String {
        guard let exercise = exercise else { return "" }
        
        switch exercise.type {
        case .weight:
            let weightText = weightUsed.map { "\(Int($0)) lbs" } ?? ""
            return "\(totalReps) total reps \(weightText)"
        case .bodyweight, .drill:
            return "\(totalReps) total reps"
        case .cardio:
            let mins = (durationCompleted ?? 0) / 60
            return "\(mins) min completed"
        }
    }
}
