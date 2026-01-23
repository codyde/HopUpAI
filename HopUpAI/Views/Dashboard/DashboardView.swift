//
//  DashboardView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Main dashboard showing level, XP, streak, and quick actions
struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \Workout.createdAt, order: .reverse) private var workouts: [Workout]
    
    @State private var showingNewWorkout = false
    @State private var showingWorkoutPicker = false
    @State private var selectedWorkout: Workout?
    @Namespace private var animation
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Hero section with level
                    heroSection
                    
                    // Stats row
                    statsRow
                    
                    // Recent workouts
                    recentWorkoutsSection
                    
                    // Quick actions
                    quickActionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                ensureProfile()
            }
            .sheet(isPresented: $showingWorkoutPicker) {
                WorkoutPickerSheet(
                    workouts: workouts,
                    onSelect: { workout in
                        showingWorkoutPicker = false
                        // Small delay to let sheet dismiss before presenting fullscreen cover
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedWorkout = workout
                        }
                    }
                )
            }
            .fullScreenCover(item: $selectedWorkout) { workout in
                NavigationStack {
                    ActiveWorkoutView(workout: workout)
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 24) {
            // Level badge
            if let profile = profile {
                LevelBadge(
                    level: profile.level,
                    title: profile.levelTitle,
                    style: .large
                )
                .matchedGeometryEffect(id: "levelBadge", in: animation)
                
                // XP Progress
                XPProgressBarHorizontal(
                    progress: profile.levelProgress,
                    currentXP: profile.currentXP,
                    xpToNextLevel: profile.xpToNextLevel
                )
            } else {
                // Loading state
                ProgressView()
                    .tint(AppColors.basketball)
            }
        }
        .padding(24)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: 16) {
            // Streak
            if let profile = profile {
                StreakIndicator(
                    streakDays: profile.currentStreak,
                    style: .medium,
                    isAtRisk: profile.isStreakAtRisk
                )
            }
        }
    }
    
    // MARK: - Recent Workouts Section
    
    private var recentWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                if !workouts.isEmpty {
                    NavigationLink {
                        WorkoutListView()
                    } label: {
                        Text("See All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.basketball)
                    }
                }
            }
            
            if workouts.isEmpty {
                CompactEmptyState(
                    icon: "clipboard",
                    message: "No workouts yet. Create one to get started!"
                )
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(workouts.prefix(3)) { workout in
                        WorkoutQuickCard(workout: workout) {
                            selectedWorkout = workout
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Quick Actions Section
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                // Start workout button
                QuickActionButton(
                    icon: "play.fill",
                    title: "Start Workout",
                    color: AppColors.basketball
                ) {
                    if workouts.isEmpty {
                        showingNewWorkout = true
                    } else if workouts.count == 1 {
                        selectedWorkout = workouts.first
                    } else {
                        showingWorkoutPicker = true
                    }
                }
                
                // Create workout button
                QuickActionButton(
                    icon: "plus",
                    title: "New Workout",
                    color: AppColors.success
                ) {
                    showingNewWorkout = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func ensureProfile() {
        if profiles.isEmpty {
            let newProfile = UserProfile(displayName: "Player")
            modelContext.insert(newProfile)
        }
    }
}

// MARK: - Supporting Views

/// Quick workout card for dashboard
struct WorkoutQuickCard: View {
    let workout: Workout
    let onStart: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.basketball.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "figure.basketball")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.basketball)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(workout.exerciseCountText)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Play button
            Button(action: onStart) {
                Image(systemName: "play.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(AppColors.basketball)
                    .clipShape(Circle())
            }
            .buttonStyle(HopUpButtonStyle())
        }
        .padding(16)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Quick action button for dashboard
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(HopUpButtonStyle())
    }
}

/// Sheet for picking a workout to start
struct WorkoutPickerSheet: View {
    let workouts: [Workout]
    let onSelect: (Workout) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(workouts) { workout in
                        Button {
                            onSelect(workout)
                        } label: {
                            HStack(spacing: 16) {
                                // Icon
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.basketball.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: "figure.basketball")
                                        .font(.system(size: 20))
                                        .foregroundStyle(AppColors.basketball)
                                }
                                
                                // Info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppColors.textPrimary)
                                    
                                    Text("\(workout.exerciseCountText) • ~\(workout.durationText)")
                                        .font(.system(size: 13))
                                        .foregroundStyle(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textTertiary)
                            }
                            .padding(16)
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(CardPressStyle())
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Start Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [UserProfile.self, Workout.self, Exercise.self], inMemory: true)
}
