//
//  APIService.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/26/26.
//

import Foundation

struct APIResponse<T>: Decodable where T: Decodable {
    let user: APIUser?
    let profile: APIUserProfile?
    let token: String?
    let exercises: [APIExercise]?
    let workouts: [APIWorkout]?
    let sessions: [APISession]?
    let syncState: APISyncState?
    let conflicts: [APISyncConflict]?
    let processedIds: [String]?
    let exercise: APIExercise?
    let workout: APIWorkout?
    let session: APISession?
    let conflictsCount: Int?
}

struct APIUser: Decodable {
    let id: String
    let appleUserId: String
    let displayName: String
    let email: String?
    let createdAt: String
}

struct APIUserProfile: Decodable {
    let id: String
    let userId: String
    let level: Int
    let currentXP: Int
    let totalXP: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastWorkoutDate: String?
    let totalWorkoutsCompleted: Int
    let createdAt: String
    let updatedAt: String
}

struct APIExercise: Decodable {
    let id: String
    let userId: String
    let name: String
    let exerciseDescription: String?
    let type: String
    let defaultSets: Int
    let defaultReps: Int
    let defaultWeight: Int?
    let defaultDuration: Int?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let needsSync: Bool
}

struct APIWorkout: Decodable {
    let id: String
    let userId: String
    let name: String
    let workoutDescription: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let needsSync: Bool
}

struct APISession: Decodable {
    let id: String
    let userId: String
    let workoutId: String
    let startedAt: String
    let completedAt: String?
    let totalXPEarned: Int
    let createdAt: String
    let updatedAt: String
    let needsSync: Bool
}

struct APISyncState: Decodable {
    let lastSyncedAt: String?
    let lastConflictResolution: String
}

struct APISyncConflict: Decodable {
    let itemId: String
    let itemType: String
    let localVersion: String
    let serverVersion: String
}

@MainActor
final class APIService {
    static let shared = APIService()
    
    private let baseURL: String
    private var authToken: String?
    
    private init() {
        // Use Railway backend for all builds
        self.baseURL = "https://hopup-api.up.railway.app/api/v1"
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    func clearAuthToken() {
        self.authToken = nil
    }
    
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> APIResponse<T> {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            let result = try decoder.decode(APIResponse<T>.self, from: data)
            return result
        case 401:
            throw APIError.unauthorized
        case 400:
            throw APIError.badRequest
        case 500:
            throw APIError.serverError
        default:
            throw APIError.unknown(httpResponse.statusCode)
        }
    }
    
    // MARK: - Authentication
    
    func signInWithApple(
        identityToken: String,
        userAppleId: String
    ) async throws -> APIResponse<EmptyResult> {
        let body = [
            "identityToken": identityToken,
            "userAppleId": userAppleId
        ]
        return try await performRequest(
            endpoint: "/auth/apple-signin",
            method: "POST",
            body: body
        )
    }
    
    func refreshToken() async throws -> APIResponse<EmptyResult> {
        return try await performRequest(endpoint: "/auth/refresh")
    }
    
    // MARK: - Exercises
    
    func getExercises() async throws -> APIResponse<[EmptyResult]> {
        return try await performRequest(endpoint: "/exercises")
    }
    
    func createExercise(_ exercise: [String: Any]) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/exercises",
            method: "POST",
            body: exercise
        )
    }
    
    func updateExercise(_ exercise: [String: Any], id: UUID) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/exercises/\(id.uuidString)",
            method: "PUT",
            body: exercise
        )
    }
    
    func deleteExercise(_ id: UUID) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/exercises/\(id.uuidString)",
            method: "DELETE"
        )
    }
    
    // MARK: - Workouts
    
    func getWorkouts() async throws -> APIResponse<[EmptyResult]> {
        return try await performRequest(endpoint: "/workouts")
    }
    
    func createWorkout(_ workout: [String: Any]) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/workouts",
            method: "POST",
            body: workout
        )
    }
    
    func updateWorkout(_ workout: [String: Any], id: UUID) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/workouts/\(id.uuidString)",
            method: "PUT",
            body: workout
        )
    }
    
    func deleteWorkout(_ id: UUID) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/workouts/\(id.uuidString)",
            method: "DELETE"
        )
    }
    
    // MARK: - Sessions
    
    func getSessions() async throws -> APIResponse<[EmptyResult]> {
        return try await performRequest(endpoint: "/sessions")
    }
    
    func createSession(_ session: [String: Any]) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/sessions",
            method: "POST",
            body: session
        )
    }
    
    func updateSession(_ session: [String: Any], id: UUID) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/sessions/\(id.uuidString)",
            method: "PUT",
            body: session
        )
    }
    
    // MARK: - Profile & Sync
    
    func getProfile() async throws -> APIResponse<EmptyResult> {
        return try await performRequest(endpoint: "/profile")
    }
    
    func updateProfile(_ profile: [String: Any]) async throws -> APIResponse<EmptyResult> {
        return try await performRequest(
            endpoint: "/profile",
            method: "PUT",
            body: profile
        )
    }
    
    func downloadSync(lastSyncedAt: Date?) async throws -> APIResponse<EmptyResult> {
        var body: [String: Any] = [:]
        
        if let lastSyncedAt = lastSyncedAt {
            body["lastSyncedAt"] = ISO8601DateFormatter().string(from: lastSyncedAt)
        }
        
        return try await performRequest(
            endpoint: "/profile/sync/download",
            method: "POST",
            body: body.isEmpty ? nil : body
        )
    }
    
    func uploadSync(
        exercises: [[String: Any]],
        workouts: [[String: Any]],
        sessions: [[String: Any]]
    ) async throws -> APIResponse<EmptyResult> {
        let body: [String: Any] = [
            "exercises": exercises,
            "workouts": workouts,
            "sessions": sessions
        ]
        
        return try await performRequest(
            endpoint: "/profile/sync/upload",
            method: "POST",
            body: body
        )
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case badRequest
    case serverError
    case unknown(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized - please sign in again"
        case .badRequest:
            return "Invalid request"
        case .serverError:
            return "Server error - please try again later"
        case .unknown(let code):
            return "Unknown error: \(code)"
        }
    }
}

struct EmptyResult: Decodable {}