//
//  ContentView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData
import UIKit

/// Root view with tab-based navigation
struct ContentView: View {
    @State private var selectedTab = 0
    
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
