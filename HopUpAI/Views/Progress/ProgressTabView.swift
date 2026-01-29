//
//  ProgressView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Progress view showing workout history and stats
struct ProgressTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutSession.startedAt, order: .reverse) private var sessions: [WorkoutSession]
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats overview
                    statsOverview
                    
                    // Workout history
                    historySection
                }
                .padding()
                .padding(.bottom, 100)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: - Stats Overview
    
    private var statsOverview: some View {
        VStack(spacing: 16) {
            // Main stats row
            HStack(spacing: 16) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(profile?.totalXP ?? 0)",
                    label: "Total XP",
                    color: AppColors.basketball
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(completedSessions.count)",
                    label: "Workouts",
                    color: AppColors.success
                )
                
                StatCard(
                    icon: "star.fill",
                    value: "\(profile?.level ?? 1)",
                    label: "Level",
                    color: AppColors.gold
                )
            }
            
            // Streak info
            if let profile = profile {
                HStack(spacing: 16) {
                    StatCard(
                        icon: "flame",
                        value: "\(profile.currentStreak)",
                        label: "Current Streak",
                        color: AppColors.fire
                    )
                    
                    StatCard(
                        icon: "trophy.fill",
                        value: "\(profile.longestStreak)",
                        label: "Best Streak",
                        color: AppColors.gold
                    )
                }
            }
        }
    }
    
    // MARK: - History Section
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout History")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            if completedSessions.isEmpty {
                CompactEmptyState(
                    icon: "chart.bar",
                    message: "Complete a workout to see your history"
                )
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(completedSessions) { session in
                        SessionHistoryRow(session: session)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Session History Row

struct SessionHistoryRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.success.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.success)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.workout?.name ?? "Unknown Workout")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                HStack(spacing: 12) {
                    Text(session.dateText)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                    
                    if let duration = session.durationText {
                        Text(duration)
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // XP earned
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(session.totalXPEarned)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.basketball)
                
                Text("XP")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProgressTabView()
        .modelContainer(for: [UserProfile.self, WorkoutSession.self, Workout.self], inMemory: true)
}
