//
//  HopUpAIApp.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

@main
struct HopUpAIApp: App {
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
                    await OfflineQueue.shared.processQueue()
                }
            }
        }
    }
    
    /// Triggers cloud sync if user is authenticated
    private func syncOnLaunchIfAuthenticated() {
        guard AuthenticationService.shared.isUserAuthenticated() else { return }
        
        Task {
            // Process offline queue first
            await OfflineQueue.shared.processQueue()
            
            // Then perform full sync
            // Note: Full SyncService.shared.performFullSync() would go here
            // once ModelContext is passed through
        }
    }
}
