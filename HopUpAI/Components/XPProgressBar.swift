//
//  XPProgressBar.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Circular XP progress bar with animated fill
struct XPProgressBar: View {
    let progress: Double
    let currentXP: Int
    let xpToNextLevel: Int
    var size: CGFloat = 200
    var lineWidth: CGFloat = 16
    var showLabels: Bool = true
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    AppColors.courtLines,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
            
            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AppColors.xpGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.basketball.opacity(0.5), radius: 8)
            
            // Center content
            if showLabels {
                VStack(spacing: 4) {
                    Text("\(currentXP)")
                        .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text("/ \(xpToNextLevel) XP")
                        .font(.system(size: size * 0.08, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(AppAnimations.bouncy.delay(0.2)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AppAnimations.bouncy) {
                animatedProgress = newValue
            }
        }
    }
}

/// Horizontal XP progress bar variant
struct XPProgressBarHorizontal: View {
    let progress: Double
    let currentXP: Int
    let xpToNextLevel: Int
    var height: CGFloat = 12
    var showLabels: Bool = true
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showLabels {
                HStack {
                    Text("\(currentXP) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.basketball)
                    
                    Spacer()
                    
                    Text("\(xpToNextLevel) to next level")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(AppColors.courtLines)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(AppColors.xpGradient)
                        .frame(width: geometry.size.width * animatedProgress)
                        .shadow(color: AppColors.basketball.opacity(0.5), radius: 4)
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(AppAnimations.bouncy.delay(0.1)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(AppAnimations.bouncy) {
                animatedProgress = newValue
            }
        }
    }
}

/// XP gain animation overlay
struct XPGainView: View {
    let amount: Int
    @State private var isVisible = true
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text("+\(amount) XP")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.gold)
            .shadow(color: AppColors.goldGlow.opacity(0.8), radius: 8)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = -50
                    opacity = 0
                }
            }
    }
}

#Preview("Circular Progress") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: 40) {
            XPProgressBar(
                progress: 0.65,
                currentXP: 180,
                xpToNextLevel: 280
            )
            
            XPProgressBar(
                progress: 0.3,
                currentXP: 85,
                xpToNextLevel: 280,
                size: 120,
                lineWidth: 10
            )
        }
    }
}

#Preview("Horizontal Progress") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: 40) {
            XPProgressBarHorizontal(
                progress: 0.65,
                currentXP: 180,
                xpToNextLevel: 280
            )
            .padding(.horizontal)
            
            XPProgressBarHorizontal(
                progress: 0.3,
                currentXP: 85,
                xpToNextLevel: 280,
                height: 8,
                showLabels: false
            )
            .padding(.horizontal)
        }
    }
}
