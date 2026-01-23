//
//  WorkoutCompleteView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Celebration view shown when workout is completed
struct WorkoutCompleteView: View {
    let workout: Workout
    let session: WorkoutSession?
    let totalXP: Int
    let duration: TimeInterval
    let onDismiss: () -> Void
    
    @Query private var profiles: [UserProfile]
    
    @State private var showContent = false
    @State private var xpCounterValue = 0
    @State private var showLevelUp = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            // Background
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Trophy icon with glow
                trophyIcon
                
                // Congratulations text
                congratsSection
                
                // Stats
                statsSection
                
                // XP earned with counter animation
                xpSection
                
                // Level progress
                if let profile = profile {
                    levelSection(profile: profile)
                }
                
                Spacer()
                
                // Done button
                doneButton
            }
            .padding(24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
        }
        .onAppear {
            withAnimation(AppAnimations.bouncy.delay(0.2)) {
                showContent = true
            }
            
            // Animate XP counter
            animateXPCounter()
        }
    }
    
    // MARK: - Trophy Icon
    
    private var trophyIcon: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(AppColors.gold.opacity(0.2))
                .frame(width: 160, height: 160)
                .blur(radius: 30)
            
            // Inner glow
            Circle()
                .fill(AppColors.gold.opacity(0.3))
                .frame(width: 100, height: 100)
            
            // Trophy
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.goldGradient)
                .shadow(color: AppColors.gold.opacity(0.5), radius: 16)
        }
        .scaleEffect(showContent ? 1.0 : 0.5)
        .animation(AppAnimations.bouncy.delay(0.3), value: showContent)
    }
    
    // MARK: - Congrats Section
    
    private var congratsSection: some View {
        VStack(spacing: 8) {
            Text("WORKOUT COMPLETE!")
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.gold)
            
            Text(workout.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 24) {
            // Duration
            VStack(spacing: 4) {
                Text(formatDuration(duration))
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Duration")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Exercises
            VStack(spacing: 4) {
                Text("\(workout.exerciseCount)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Exercises")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - XP Section
    
    private var xpSection: some View {
        VStack(spacing: 8) {
            Text("+\(xpCounterValue)")
                .font(.system(size: 56, weight: .black, design: .rounded))
                .foregroundStyle(AppColors.basketball)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: xpCounterValue)
            
            Text("XP EARNED")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.basketball.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.basketball.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Level Section
    
    private func levelSection(profile: UserProfile) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level \(profile.level)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(profile.levelTitle.color)
                
                Spacer()
                
                Text(profile.levelTitle.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.courtLines)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppColors.xpGradient)
                        .frame(width: geometry.size.width * profile.levelProgress)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(profile.currentXP) XP")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.basketball)
                
                Spacer()
                
                Text("\(profile.xpToNextLevel - profile.currentXP) to level \(profile.level + 1)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(20)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Done Button
    
    private var doneButton: some View {
        Button(action: onDismiss) {
            Text("Done")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColors.basketballGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(HopUpButtonStyle())
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func animateXPCounter() {
        // Animate from 0 to totalXP
        let steps = 20
        let stepDuration = 1.0 / Double(steps)
        let stepValue = totalXP / steps
        
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * stepDuration) {
                if i == steps {
                    xpCounterValue = totalXP
                } else {
                    xpCounterValue = stepValue * i
                }
            }
        }
    }
}

#Preview {
    WorkoutCompleteView(
        workout: Workout(name: "Morning Warmup"),
        session: nil,
        totalXP: 285,
        duration: 1234,
        onDismiss: {}
    )
    .modelContainer(for: [UserProfile.self, Workout.self], inMemory: true)
}
