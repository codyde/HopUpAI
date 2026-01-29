//
//  HopUpAIApp.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import Sentry

import SwiftData

@main
struct HopUpAIApp: App {
    init() {
        SentrySDK.start { options in
            options.dsn = "https://98fcd9440b132b7e173f87122033b37a@o4508130833793024.ingest.us.sentry.io/4510795297390592"

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0

            // Configure profiling. Visit https://docs.sentry.io/platforms/apple/profiling/ to learn more.
            options.configureProfiling = {
                $0.sessionSampleRate = 1.0 // We recommend adjusting this value in production.
                $0.lifecycle = .trace
            }

            // Session Replay - captures user sessions for debugging
            options.sessionReplay.sessionSampleRate = 1.0 // 100% of sessions, reduce in production
            options.sessionReplay.onErrorSampleRate = 1.0 // 100% of sessions with errors

            // Add more context to error events
            options.attachScreenshot = true
            options.attachViewHierarchy = true
            
            // Enable logging
            options.enableLogs = true
        }
        // Remove the next line after confirming that your Sentry integration is working.
        SentrySDK.capture(message: "This app uses Sentry! :)")
    }
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            Workout.self,
            WorkoutExercise.self,
            WorkoutSession.self,
            ExerciseLog.self,
            UserProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    syncOnLaunchIfAuthenticated()
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Process any offline queue items when app becomes active
                Task {
                    try? await OfflineQueue.shared.processQueue()
                }
            }
        }
    }
    
    /// Triggers cloud sync if user is authenticated
    private func syncOnLaunchIfAuthenticated() {
        guard AuthenticationService.shared.isUserAuthenticated() else { return }
        
        Task {
            // Process offline queue first
            try? await OfflineQueue.shared.processQueue()
            
            // Then perform full sync
            // Note: Full SyncService.shared.performFullSync() would go here
            // once ModelContext is passed through
        }
    }
}
