//
//  StreakIndicator.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Display current workout streak with fire animation
struct StreakIndicator: View {
    let streakDays: Int
    var style: StreakStyle = .large
    var isAtRisk: Bool = false
    
    @State private var isAnimating = false
    
    var body: some View {
        switch style {
        case .large:
            largeStreak
        case .medium:
            mediumStreak
        case .compact:
            compactStreak
        }
    }
    
    // MARK: - Large Style
    
    private var largeStreak: some View {
        VStack(spacing: 8) {
            ZStack {
                // Fire glow
                if streakDays > 0 {
                    Circle()
                        .fill(AppColors.fire.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                }
                
                // Fire icon
                Image(systemName: streakDays > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        streakDays > 0
                            ? AppColors.fireGradient
                            : LinearGradient(colors: [AppColors.textTertiary], startPoint: .bottom, endPoint: .top)
                    )
                    .shadow(color: streakDays > 0 ? AppColors.fire.opacity(0.5) : .clear, radius: 8)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
            }
            
            // Streak count
            HStack(spacing: 4) {
                Text("\(streakDays)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(streakDays > 0 ? AppColors.fire : AppColors.textTertiary)
                
                Text("day\(streakDays == 1 ? "" : "s")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            // At risk warning
            if isAtRisk && streakDays > 0 {
                Text("Work out today to keep your streak!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.warning)
                    .padding(.top, 4)
            }
            
            // Bonus indicator
            if streakDays > 0 {
                let bonus = Int((XPService.streakMultiplier(for: streakDays) - 1) * 100)
                Text("+\(bonus)% XP Bonus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(AppColors.gold.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .onAppear {
            if streakDays > 0 {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
    
    // MARK: - Medium Style
    
    private var mediumStreak: some View {
        HStack(spacing: 12) {
            // Fire icon with glow
            ZStack {
                if streakDays > 0 {
                    Circle()
                        .fill(AppColors.fire.opacity(0.2))
                        .frame(width: 44, height: 44)
                }
                
                Image(systemName: streakDays > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        streakDays > 0 ? AppColors.fire : AppColors.textTertiary
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text("\(streakDays)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(streakDays > 0 ? AppColors.fire : AppColors.textTertiary)
                    
                    Text("day streak")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                if streakDays > 0 {
                    let bonus = Int((XPService.streakMultiplier(for: streakDays) - 1) * 100)
                    Text("+\(bonus)% XP")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
            
            Spacer()
            
            // At risk indicator
            if isAtRisk && streakDays > 0 {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.warning)
            }
        }
        .padding(16)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Compact Style
    
    private var compactStreak: some View {
        HStack(spacing: 4) {
            Image(systemName: streakDays > 0 ? "flame.fill" : "flame")
                .font(.system(size: 14))
                .foregroundStyle(streakDays > 0 ? AppColors.fire : AppColors.textTertiary)
            
            Text("\(streakDays)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(streakDays > 0 ? AppColors.fire : AppColors.textTertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            streakDays > 0
                ? AppColors.fire.opacity(0.15)
                : AppColors.courtLines
        )
        .clipShape(Capsule())
    }
}

/// Streak display styles
enum StreakStyle {
    case large   // Full display with animation
    case medium  // Card style
    case compact // Pill badge
}

#Preview("Streak Indicators") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 40) {
                StreakIndicator(streakDays: 7, style: .large)
                
                StreakIndicator(streakDays: 0, style: .large)
                
                StreakIndicator(streakDays: 5, style: .medium, isAtRisk: true)
                    .padding(.horizontal)
                
                StreakIndicator(streakDays: 3, style: .medium)
                    .padding(.horizontal)
                
                HStack(spacing: 12) {
                    StreakIndicator(streakDays: 0, style: .compact)
                    StreakIndicator(streakDays: 3, style: .compact)
                    StreakIndicator(streakDays: 10, style: .compact)
                }
            }
            .padding()
        }
    }
}
