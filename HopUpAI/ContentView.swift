//
//  ContentView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData
import UIKit

/// Root view - shows sign in or main app based on auth state
struct ContentView: View {
    @State private var isAuthenticated = AuthenticationService.shared.isUserAuthenticated()
    
    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView(isAuthenticated: $isAuthenticated)
            } else {
                SignInView(isAuthenticated: $isAuthenticated)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isAuthenticated)
    }
}

/// Main tab-based navigation
struct MainTabView: View {
    @Binding var isAuthenticated: Bool
    @State private var selectedTab = 0
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var userInitial: String {
        let name = UserDefaults.standard.string(forKey: "userDisplayName") ?? profile?.displayName ?? "U"
        return String(name.prefix(1)).uppercased()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            ExerciseListView()
                .tabItem {
                    Label("Exercises", systemImage: "figure.basketball")
                }
                .tag(1)
            
            WorkoutListView()
                .tabItem {
                    Label("Workouts", systemImage: "clipboard.fill")
                }
                .tag(2)
            
            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(AppColors.basketball)
        .preferredColorScheme(.dark)
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppColors.court)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Exercise.self,
            Workout.self,
            WorkoutExercise.self,
            WorkoutSession.self,
            ExerciseLog.self,
            UserProfile.self
        ], inMemory: true)
}
