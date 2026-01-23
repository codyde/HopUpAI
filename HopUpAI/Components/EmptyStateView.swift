//
//  EmptyStateView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Empty state view for when lists have no content
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                // Glow
                Circle()
                    .fill(AppColors.basketball.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundStyle(AppColors.basketball.opacity(0.6))
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
            }
            
            // Text content
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text(actionTitle)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(32)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

/// Preset empty states for different sections
extension EmptyStateView {
    static var exercises: EmptyStateView {
        EmptyStateView(
            icon: "figure.basketball",
            title: "No Exercises Yet",
            message: "Create your first exercise to start building workouts",
            actionTitle: "Create Exercise"
        )
    }
    
    static var workouts: EmptyStateView {
        EmptyStateView(
            icon: "clipboard",
            title: "No Workouts Yet",
            message: "Build a workout by combining your exercises",
            actionTitle: "Create Workout"
        )
    }
    
    static var progress: EmptyStateView {
        EmptyStateView(
            icon: "chart.bar",
            title: "No Workouts Completed",
            message: "Complete your first workout to start tracking progress"
        )
    }
    
    static var workoutExercises: EmptyStateView {
        EmptyStateView(
            icon: "plus.circle",
            title: "No Exercises Added",
            message: "Add exercises to build your workout",
            actionTitle: "Add Exercise"
        )
    }
}

/// Compact empty state for inline use
struct CompactEmptyState: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(AppColors.textTertiary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

#Preview("Empty States") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 60) {
                EmptyStateView.exercises
                
                Divider()
                    .background(AppColors.courtLines)
                
                EmptyStateView.workouts
                
                Divider()
                    .background(AppColors.courtLines)
                
                EmptyStateView.progress
                
                Divider()
                    .background(AppColors.courtLines)
                
                CompactEmptyState(
                    icon: "tray",
                    message: "No items to display"
                )
            }
        }
    }
}
