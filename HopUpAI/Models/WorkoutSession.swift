//
//  WorkoutSession.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import Foundation
import SwiftData

/// A recorded instance of completing a workout
@Model
final class WorkoutSession {
    // MARK: - Properties
    
    var id: UUID
    var startedAt: Date
    var completedAt: Date?
    var totalXPEarned: Int
    var updatedAt: Date
    var needsSync: Bool
    
    // MARK: - Relationships
    
    var workout: Workout?
    
    @Relationship(deleteRule: .cascade, inverse: \ExerciseLog.session)
    var exerciseLogs: [ExerciseLog]?
    
    // MARK: - Computed Properties
    
    /// Whether this session has been completed
    var isCompleted: Bool {
        completedAt != nil
    }
    
    /// Duration of the workout in seconds
    var durationSeconds: Int? {
        guard let completedAt = completedAt else { return nil }
        return Int(completedAt.timeIntervalSince(startedAt))
    }
    
    /// Formatted duration string
    var durationText: String? {
        guard let seconds = durationSeconds else { return nil }
        let minutes = seconds / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMins = minutes % 60
            return "\(hours)h \(remainingMins)m"
        }
        return "\(minutes) min"
    }
    
    /// Number of exercises completed in this session
    var completedExerciseCount: Int {
        exerciseLogs?.filter { $0.isCompleted }.count ?? 0
    }
    
    /// Total exercises in the workout
    var totalExerciseCount: Int {
        workout?.exerciseCount ?? 0
    }
    
    /// Progress percentage (0.0 - 1.0)
    var progress: Double {
        guard totalExerciseCount > 0 else { return 0 }
        return Double(completedExerciseCount) / Double(totalExerciseCount)
    }
    
    // MARK: - Initialization
    
    init(workout: Workout) {
        self.id = UUID()
        self.workout = workout
        self.startedAt = Date()
        self.completedAt = nil
        self.totalXPEarned = 0
        self.updatedAt = Date()
        self.needsSync = false
    }
}

// MARK: - Session Management

extension WorkoutSession {
    /// Mark the session as completed
    func complete() {
        self.completedAt = Date()
    }
    
    /// Add XP earned
    func addXP(_ amount: Int) {
        self.totalXPEarned += amount
    }
}

// MARK: - Display Helpers

extension WorkoutSession {
    /// Date formatted for display
    var dateText: String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(startedAt) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if Calendar.current.isDateInYesterday(startedAt) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateFormat = "MMM d 'at' h:mm a"
        }
        return formatter.string(from: startedAt)
    }
    
    /// Status text
    var statusText: String {
        if isCompleted {
            return "Completed"
        } else {
            return "In Progress"
        }
    }
}