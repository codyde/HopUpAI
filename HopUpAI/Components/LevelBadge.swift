//
//  LevelBadge.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Display badge for user level and title
struct LevelBadge: View {
    let level: Int
    let title: LevelTitle
    var style: LevelBadgeStyle = .large
    
    @State private var isAnimating = false
    
    var body: some View {
        switch style {
        case .large:
            largeBadge
        case .medium:
            mediumBadge
        case .compact:
            compactBadge
        case .minimal:
            minimalBadge
        }
    }
    
    // MARK: - Large Style
    
    private var largeBadge: some View {
        VStack(spacing: 8) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(title.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                
                // Level number
                Text("\(level)")
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(title.color)
            }
            
            // Title
            HStack(spacing: 6) {
                Image(systemName: title.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(title.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(title.color.opacity(0.15))
            .clipShape(Capsule())
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Medium Style
    
    private var mediumBadge: some View {
        HStack(spacing: 12) {
            // Level circle
            ZStack {
                Circle()
                    .fill(title.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text("\(level)")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(title.color)
            }
            
            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(level)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                
                HStack(spacing: 4) {
                    Image(systemName: title.icon)
                        .font(.system(size: 12))
                    Text(title.rawValue)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(title.color)
            }
        }
    }
    
    // MARK: - Compact Style
    
    private var compactBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: title.icon)
                .font(.system(size: 12, weight: .semibold))
            
            Text("Lv.\(level)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .foregroundStyle(title.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(title.color.opacity(0.15))
        .clipShape(Capsule())
    }
    
    // MARK: - Minimal Style
    
    private var minimalBadge: some View {
        Text("Lv.\(level)")
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(title.color)
    }
}

/// Badge display styles
enum LevelBadgeStyle {
    case large    // Full display with animation
    case medium   // Side-by-side layout
    case compact  // Pill badge
    case minimal  // Text only
}

/// Level up celebration view
struct LevelUpCelebration: View {
    let newLevel: Int
    let newTitle: LevelTitle
    var onDismiss: () -> Void = {}
    
    @State private var showContent = false
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 32) {
                // Header
                Text("LEVEL UP!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(AppColors.gold)
                    .shadow(color: AppColors.goldGlow, radius: 16)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Level badge
                LevelBadge(level: newLevel, title: newTitle, style: .large)
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1 : 0)
                
                // Message
                if newTitle != LevelTitle.forLevel(newLevel - 1) {
                    Text("You've reached \(newTitle.rawValue)!")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(newTitle.color)
                        .opacity(showContent ? 1 : 0)
                }
                
                // Continue button
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(AppColors.basketballGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(HopUpButtonStyle())
                .opacity(showContent ? 1 : 0)
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(AppAnimations.bouncy.delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                showConfetti = true
            }
        }
    }
}

#Preview("Level Badges") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 40) {
                LevelBadge(level: 12, title: .varsity, style: .large)
                
                LevelBadge(level: 45, title: .allStar, style: .medium)
                
                HStack(spacing: 12) {
                    LevelBadge(level: 5, title: .rookie, style: .compact)
                    LevelBadge(level: 75, title: .allAmerican, style: .compact)
                    LevelBadge(level: 100, title: .mvp, style: .compact)
                }
                
                HStack(spacing: 20) {
                    ForEach([1, 10, 25, 50, 80, 100], id: \.self) { level in
                        LevelBadge(level: level, title: LevelTitle.forLevel(level), style: .minimal)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Level Up") {
    LevelUpCelebration(newLevel: 16, newTitle: .varsity)
}
