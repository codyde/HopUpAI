//
//  AppAnimations.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import UIKit

/// Animation constants and utilities for HopUpAI
enum AppAnimations {
    // MARK: - Spring Animations
    
    /// Standard spring for most interactions
    static let standard = Animation.spring(response: 0.35, dampingFraction: 0.8)
    
    /// Bouncy spring for playful elements (XP gain, level up)
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    
    /// Snappy spring for quick responses
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.9)
    
    /// Gentle spring for subtle movements
    static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.85)
    
    // MARK: - Timing Animations
    
    /// Quick ease for micro-interactions
    static let quick = Animation.easeOut(duration: 0.15)
    
    /// Medium ease for transitions
    static let medium = Animation.easeInOut(duration: 0.3)
    
    /// Slow ease for emphasis
    static let slow = Animation.easeInOut(duration: 0.5)
    
    // MARK: - Durations
    
    static let durationQuick: Double = 0.15
    static let durationMedium: Double = 0.3
    static let durationSlow: Double = 0.5
    static let durationLevelUp: Double = 1.5
    
    // MARK: - Stagger Delays
    
    /// Delay per item for staggered list animations
    static let staggerDelay: Double = 0.05
    
    /// Delay for sequential animations
    static let sequenceDelay: Double = 0.1
}

// MARK: - Custom Transitions

extension AnyTransition {
    /// Slide up from bottom with fade
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }
    
    /// Slide from trailing edge
    static var slideTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Scale up with fade
    static var scaleUp: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }
    
    /// Pop in effect for achievements/XP
    static var popIn: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 1.2).combined(with: .opacity)
        )
    }
}

// MARK: - Button Styles

/// Standard button style with scale and haptic feedback
struct HopUpButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(AppAnimations.snappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
    }
}

/// Card press style with slight lift effect
struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(
                color: AppColors.basketball.opacity(configuration.isPressed ? 0.3 : 0),
                radius: configuration.isPressed ? 8 : 0
            )
            .animation(AppAnimations.snappy, value: configuration.isPressed)
    }
}

/// Primary action button style (basketball orange)
struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Group {
                    if isEnabled {
                        AppColors.basketballGradient
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
            )
            .foregroundStyle(isEnabled ? AppColors.textPrimary : AppColors.textTertiary)
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppAnimations.snappy, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed && isEnabled {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
    }
}

// MARK: - View Modifiers

/// Staggered appearance animation modifier
struct StaggeredAppearance: ViewModifier {
    let index: Int
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .onAppear {
                withAnimation(AppAnimations.standard.delay(Double(index) * AppAnimations.staggerDelay)) {
                    hasAppeared = true
                }
            }
    }
}

/// Pulse animation for emphasis
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    var color: Color = AppColors.basketball
    
    func body(content: Content) -> some View {
        content
            .overlay(
                content
                    .foregroundStyle(color)
                    .scaleEffect(isPulsing ? 1.2 : 1.0)
                    .opacity(isPulsing ? 0 : 0.5)
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }
    }
}

/// Glow effect for highlighted elements
struct GlowEffect: ViewModifier {
    var color: Color = AppColors.basketball
    var radius: CGFloat = 8
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}

extension View {
    /// Apply staggered appearance animation
    func staggeredAppearance(index: Int) -> some View {
        modifier(StaggeredAppearance(index: index))
    }
    
    /// Apply pulse animation
    func pulseAnimation(color: Color = AppColors.basketball) -> some View {
        modifier(PulseAnimation(color: color))
    }
    
    /// Apply glow effect
    func glowEffect(color: Color = AppColors.basketball, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}
