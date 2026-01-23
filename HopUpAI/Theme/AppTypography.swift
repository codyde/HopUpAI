//
//  AppTypography.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Typography system for HopUpAI
enum AppTypography {
    // MARK: - Font Sizes
    
    static let largeTitle: CGFloat = 34
    static let title: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    static let headline: CGFloat = 17
    static let body: CGFloat = 17
    static let callout: CGFloat = 16
    static let subheadline: CGFloat = 15
    static let footnote: CGFloat = 13
    static let caption: CGFloat = 12
    static let caption2: CGFloat = 11
    
    // MARK: - XP/Level Display
    
    static let levelNumber: CGFloat = 64
    static let xpCounter: CGFloat = 48
    static let streakNumber: CGFloat = 32
}

// MARK: - Font Modifiers

extension View {
    /// Large title style - for main headers
    func largeTitleStyle() -> some View {
        self
            .font(.system(size: AppTypography.largeTitle, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Title style - for section headers
    func titleStyle() -> some View {
        self
            .font(.system(size: AppTypography.title, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Title 2 style
    func title2Style() -> some View {
        self
            .font(.system(size: AppTypography.title2, weight: .semibold, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Title 3 style
    func title3Style() -> some View {
        self
            .font(.system(size: AppTypography.title3, weight: .semibold, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Headline style - for list item titles
    func headlineStyle() -> some View {
        self
            .font(.system(size: AppTypography.headline, weight: .semibold))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Body style - for main content
    func bodyStyle() -> some View {
        self
            .font(.system(size: AppTypography.body, weight: .regular))
            .foregroundStyle(AppColors.textPrimary)
    }
    
    /// Secondary body style - muted text
    func secondaryStyle() -> some View {
        self
            .font(.system(size: AppTypography.body, weight: .regular))
            .foregroundStyle(AppColors.textSecondary)
    }
    
    /// Caption style - for metadata
    func captionStyle() -> some View {
        self
            .font(.system(size: AppTypography.caption, weight: .medium))
            .foregroundStyle(AppColors.textSecondary)
    }
    
    /// Level number display
    func levelNumberStyle() -> some View {
        self
            .font(.system(size: AppTypography.levelNumber, weight: .black, design: .rounded))
            .foregroundStyle(AppColors.gold)
    }
    
    /// XP counter display
    func xpCounterStyle() -> some View {
        self
            .font(.system(size: AppTypography.xpCounter, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.basketball)
    }
    
    /// Streak number display
    func streakNumberStyle() -> some View {
        self
            .font(.system(size: AppTypography.streakNumber, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.fire)
    }
}

// MARK: - Text Styles Enum

enum TextStyle {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case secondary
    case caption
    case levelNumber
    case xpCounter
    case streakNumber
}

extension View {
    @ViewBuilder
    func textStyle(_ style: TextStyle) -> some View {
        switch style {
        case .largeTitle:
            self.largeTitleStyle()
        case .title:
            self.titleStyle()
        case .title2:
            self.title2Style()
        case .title3:
            self.title3Style()
        case .headline:
            self.headlineStyle()
        case .body:
            self.bodyStyle()
        case .secondary:
            self.secondaryStyle()
        case .caption:
            self.captionStyle()
        case .levelNumber:
            self.levelNumberStyle()
        case .xpCounter:
            self.xpCounterStyle()
        case .streakNumber:
            self.streakNumberStyle()
        }
    }
}
