//
//  SyncService.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/26/26.
//

import Foundation
import SwiftData

protocol Syncable {
    var id: UUID { get }
    var updatedAt: Date { get set }
    var needsSync: Bool { get set }
    func toDictionary() -> [String: Any]
}

extension Exercise: Syncable {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "exerciseDescription": exerciseDescription ?? "",
            "type": type.rawValue,
            "defaultSets": defaultSets,
            "defaultReps": defaultReps,
            "defaultWeight": defaultWeight ?? 0,
            "defaultDuration": defaultDuration ?? 0,
            "needsSync": needsSync,
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }
}

extension Workout: Syncable {
    func toDictionary() -> [String: Any] {
        [
            "id": id.uuidString,
            "name": name,
            "workoutDescription": workoutDescription ?? "",
            "needsSync": needsSync,
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
    }
}

extension WorkoutSession: Syncable {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id.uuidString,
            "workoutId": workout?.id.uuidString ?? "",
            "startedAt": ISO8601DateFormatter().string(from: startedAt),
            "totalXPEarned": totalXPEarned,
            "needsSync": needsSync,
            "updatedAt": ISO8601DateFormatter().string(from: updatedAt)
        ]
        
        if let completedAt = completedAt {
            dict["completedAt"] = ISO8601DateFormatter().string(from: completedAt)
        }
        
        return dict
    }
}

@MainActor
final class SyncService {
    static let shared = SyncService()
    
    private let modelContext: ModelContext
    private let apiService = APIService.shared
    
    private init() {
        self.modelContext = ModelContext.shared
    }
    
    func downloadSync() async throws {
        let lastSyncedAt = UserDefaults.standard.object(forKey: "lastSyncedAt") as? Date
        
        let response = try await apiService.downloadSync(lastSyncedAt: lastSyncedAt)
        
        if let profileData = response.user {
            print("Received profile: \(profileData)")
        }
        
        if let exercises = response.exercises {
            for apiExercise in exercises {
                try await mergeOrInsertExercise(apiExercise)
            }
        }
        
        if let workouts = response.workouts {
            for apiWorkout in workouts {
                try await mergeOrInsertWorkout(apiWorkout)
            }
        }
        
        if let sessions = response.sessions {
            for apiSession in sessions {
                try await mergeOrInsertSession(apiSession)
            }
        }
        
        UserDefaults.standard.set(Date(), forKey: "lastSyncAt")
    }
    
    func uploadPendingChanges() async throws {
        let exerciseDescriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.needsSync })
        let unsyncedExercises = try modelContext.fetch(exerciseDescriptor)
        
        let workoutDescriptor = FetchDescriptor<Workout>(predicate: #Predicate { $0.needsSync })
        let unsyncedWorkouts = try modelContext.fetch(workoutDescriptor)
        
        let sessionDescriptor = FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.needsSync })
        let unsyncedSessions = try modelContext.fetch(sessionDescriptor)
        
        let response = try await apiService.uploadSync(
            exercises: unsyncedExercises.map { $0.toDictionary() },
            workouts: unsyncedWorkouts.map { $0.toDictionary() },
            sessions: unsyncedSessions.map { $0.toDictionary() }
        )
        
        for exercise in unsyncedExercises {
            exercise.needsSync = false
        }
        
        for workout in unsyncedWorkouts {
            workout.needsSync = false
        }
        
        for session in unsyncedSessions {
            session.needsSync = false
        }
        
        try modelContext.save()
        
        if let conflicts = response.conflicts, !conflicts.isEmpty {
            print("Sync conflicts detected: \(conflicts)")
        }
    }
    
    func performFullSync() async throws {
        try await downloadSync()
        try await uploadPendingChanges()
    }
    
    // MARK: - Private Methods
    
    private func mergeOrInsertExercise(_ apiExercise: APIExercise) async throws {
        let uuid = UUID(uuidString: apiExercise.id) ?? UUID()
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate { $0.id == uuid }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            let existingDate = existing.updatedAt
            let serverDate = ISO8601DateFormatter().date(from: apiExercise.updatedAt) ?? Date()
            
            if serverDate > existingDate {
                existing.name = apiExercise.name
                existing.exerciseDescription = apiExercise.exerciseDescription
                if let type = ExerciseType(rawValue: apiExercise.type) {
                    existing.type = type
                }
                existing.defaultSets = apiExercise.defaultSets
                existing.defaultReps = apiExercise.defaultReps
                existing.defaultWeight = apiExercise.defaultWeight
                existing.defaultDuration = apiExercise.defaultDuration
                existing.updatedAt = serverDate
                existing.needsSync = false
                try modelContext.save()
            }
        } else {
            let newExercise = Exercise(
                name: apiExercise.name,
                exerciseDescription: apiExercise.exerciseDescription,
                type: ExerciseType(rawValue: apiExercise.type) ?? .bodyweight,
                defaultSets: apiExercise.defaultSets,
                defaultReps: apiExercise.defaultReps,
                defaultWeight: apiExercise.defaultWeight,
                defaultDuration: apiExercise.defaultDuration
            )
            newExercise.id = uuid
            if let apiUpdatedAt = ISO8601DateFormatter().date(from: apiExercise.updatedAt) {
                newExercise.updatedAt = apiUpdatedAt
            }
            modelContext.insert(newExercise)
            try modelContext.save()
        }
    }
    
    private func mergeOrInsertWorkout(_ apiWorkout: APIWorkout) async throws {
        let uuid = UUID(uuidString: apiWorkout.id) ?? UUID()
        let descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.id == uuid }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            let existingDate = existing.updatedAt
            let serverDate = ISO8601DateFormatter().date(from: apiWorkout.updatedAt) ?? Date()
            
            if serverDate > existingDate {
                existing.name = apiWorkout.name
                existing.workoutDescription = apiWorkout.workoutDescription
                existing.updatedAt = serverDate
                existing.needsSync = false
                try modelContext.save()
            }
        } else {
            let newWorkout = Workout(
                name: apiWorkout.name,
                workoutDescription: apiWorkout.workoutDescription
            )
            newWorkout.id = uuid
            if let apiUpdatedAt = ISO8601DateFormatter().date(from: apiWorkout.updatedAt) {
                newWorkout.updatedAt = apiUpdatedAt
            }
            modelContext.insert(newWorkout)
            try modelContext.save()
        }
    }
    
    private func mergeOrInsertSession(_ apiSession: APISession) async throws {
        let uuid = UUID(uuidString: apiSession.id) ?? UUID()
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.id == uuid }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            let serverCompleted = apiSession.completedAt.flatMap { ISO8601DateFormatter().date(from: $0) }
            
            if !existing.completedAt || (existing.completedAt ?? Date()) > (serverCompleted ?? Date()) {
                if let serverCompleted = serverCompleted {
                    existing.completedAt = serverCompleted
                    existing.totalXPEarned = apiSession.totalXPEarned
                    if let serverUpdatedAt = ISO8601DateFormatter().date(from: apiSession.updatedAt) {
                        existing.updatedAt = serverUpdatedAt
                    }
                    existing.needsSync = false
                    try modelContext.save()
                }
            }
        } else {
            guard let workoutUUID = UUID(uuidString: apiSession.workoutId) else {
                print("Invalid workout ID for session")
                return
            }
            
            let startedAt = ISO8601DateFormatter().date(from: apiSession.startedAt) ?? Date()
            let completedAt = apiSession.completedAt.flatMap { ISO8601DateFormatter().date(from: $0) }
            
            let newWorkout = Workout(name: "Imported Session")
            newWorkout.id = workoutUUID
            
            let newSession = WorkoutSession(workout: newWorkout)
            newSession.id = uuid
            newSession.startedAt = startedAt
            newSession.completedAt = completedAt
            newSession.totalXPEarned = apiSession.totalXPEarned
            if let serverUpdatedAt = ISO8601DateFormatter().date(from: apiSession.updatedAt) {
                newSession.updatedAt = serverUpdatedAt
            }
            
            modelContext.insert(newWorkout)
            modelContext.insert(newSession)
            try modelContext.save()
        }
    }
}

extension ModelContext {
    static let shared: ModelContext = {
        let schema = Schema([
            Exercise.self,
            Workout.self,
            WorkoutExercise.self,
            WorkoutSession.self,
            ExerciseLog.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [modelConfiguration]).mainContext
    }()
}