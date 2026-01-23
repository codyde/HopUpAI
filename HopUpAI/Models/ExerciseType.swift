//
//  ExerciseType.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Types of exercises supported in HopUpAI
enum ExerciseType: String, CaseIterable, Codable {
    case weight = "weight"
    case bodyweight = "bodyweight"
    case cardio = "cardio"
    case drill = "drill"
    
    // MARK: - Display Properties
    
    var displayName: String {
        switch self {
        case .weight: return "Weight Training"
        case .bodyweight: return "Bodyweight"
        case .cardio: return "Cardio"
        case .drill: return "Basketball Drill"
        }
    }
    
    var shortName: String {
        switch self {
        case .weight: return "Weight"
        case .bodyweight: return "Body"
        case .cardio: return "Cardio"
        case .drill: return "Drill"
        }
    }
    
    var icon: String {
        switch self {
        case .weight: return "dumbbell.fill"
        case .bodyweight: return "figure.strengthtraining.traditional"
        case .cardio: return "figure.run"
        case .drill: return "basketball.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .weight: return AppColors.typeWeight
        case .bodyweight: return AppColors.typeBodyweight
        case .cardio: return AppColors.typeCardio
        case .drill: return AppColors.typeDrill
        }
    }
    
    // MARK: - Tracking Properties
    
    /// Whether this exercise type uses weight tracking
    var usesWeight: Bool {
        switch self {
        case .weight: return true
        case .bodyweight, .cardio, .drill: return false
        }
    }
    
    /// Whether this exercise type uses duration (time-based)
    var usesDuration: Bool {
        switch self {
        case .cardio: return true
        case .weight, .bodyweight, .drill: return false
        }
    }
    
    /// Whether this exercise type uses reps
    var usesReps: Bool {
        switch self {
        case .weight, .bodyweight, .drill: return true
        case .cardio: return false
        }
    }
    
    /// Default unit label for this type
    var unitLabel: String {
        switch self {
        case .weight: return "lbs"
        case .bodyweight: return "reps"
        case .cardio: return "min"
        case .drill: return "reps"
        }
    }
    
    // MARK: - Sorting
    
    var sortOrder: Int {
        switch self {
        case .drill: return 0    // Basketball drills first
        case .weight: return 1
        case .bodyweight: return 2
        case .cardio: return 3
        }
    }
}

// MARK: - Comparable

extension ExerciseType: Comparable {
    static func < (lhs: ExerciseType, rhs: ExerciseType) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
