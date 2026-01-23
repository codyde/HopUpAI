//
//  ExerciseTypeBadge.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// Badge displaying exercise type with icon and color
struct ExerciseTypeBadge: View {
    let type: ExerciseType
    var style: BadgeStyle = .standard
    
    var body: some View {
        switch style {
        case .standard:
            standardBadge
        case .compact:
            compactBadge
        case .iconOnly:
            iconOnlyBadge
        case .pill:
            pillBadge
        }
    }
    
    // MARK: - Standard Style
    
    private var standardBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon)
                .font(.system(size: 12, weight: .semibold))
            
            Text(type.shortName)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(type.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(type.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Compact Style
    
    private var compactBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 10, weight: .semibold))
            
            Text(type.shortName)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(type.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(type.color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: - Icon Only Style
    
    private var iconOnlyBadge: some View {
        Image(systemName: type.icon)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(type.color)
            .frame(width: 28, height: 28)
            .background(type.color.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Pill Style
    
    private var pillBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .semibold))
            
            Text(type.displayName)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundStyle(type.color)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(type.color.opacity(0.15))
        .clipShape(Capsule())
    }
}

/// Badge display styles
enum BadgeStyle {
    case standard  // Icon + short name
    case compact   // Smaller version
    case iconOnly  // Just the icon
    case pill      // Full name in pill shape
}

/// Exercise type picker for forms
struct ExerciseTypePicker: View {
    @Binding var selectedType: ExerciseType
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ExerciseType.allCases, id: \.self) { type in
                Button {
                    withAnimation(AppAnimations.snappy) {
                        selectedType = type
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: type.icon)
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text(type.shortName)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(
                        selectedType == type
                            ? type.color
                            : AppColors.textSecondary
                    )
                    .background(
                        selectedType == type
                            ? type.color.opacity(0.15)
                            : AppColors.courtLines.opacity(0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedType == type
                                    ? type.color.opacity(0.5)
                                    : Color.clear,
                                lineWidth: 2
                            )
                    )
                }
                .buttonStyle(HopUpButtonStyle(scaleAmount: 0.97))
            }
        }
    }
}

/// Horizontal scrolling type filter
struct ExerciseTypeFilter: View {
    @Binding var selectedTypes: Set<ExerciseType>
    var allowMultiple: Bool = true
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All filter
                Button {
                    withAnimation(AppAnimations.snappy) {
                        if selectedTypes.count == ExerciseType.allCases.count {
                            // Deselect all not allowed, keep all selected
                        } else {
                            selectedTypes = Set(ExerciseType.allCases)
                        }
                    }
                } label: {
                    Text("All")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(
                            selectedTypes.count == ExerciseType.allCases.count
                                ? AppColors.basketball
                                : AppColors.textSecondary
                        )
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            selectedTypes.count == ExerciseType.allCases.count
                                ? AppColors.basketball.opacity(0.15)
                                : AppColors.courtLines
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(HopUpButtonStyle(scaleAmount: 0.97))
                
                // Type filters
                ForEach(ExerciseType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(AppAnimations.snappy) {
                            if allowMultiple {
                                if selectedTypes.contains(type) {
                                    if selectedTypes.count > 1 {
                                        selectedTypes.remove(type)
                                    }
                                } else {
                                    selectedTypes.insert(type)
                                }
                            } else {
                                selectedTypes = [type]
                            }
                        }
                    } label: {
                        ExerciseTypeBadge(type: type, style: .standard)
                            .opacity(selectedTypes.contains(type) ? 1.0 : 0.5)
                    }
                    .buttonStyle(HopUpButtonStyle(scaleAmount: 0.97))
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Exercise Type Badges") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 32) {
                // Standard badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Standard").captionStyle()
                    HStack(spacing: 8) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            ExerciseTypeBadge(type: type, style: .standard)
                        }
                    }
                }
                
                // Compact badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Compact").captionStyle()
                    HStack(spacing: 8) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            ExerciseTypeBadge(type: type, style: .compact)
                        }
                    }
                }
                
                // Icon only
                VStack(alignment: .leading, spacing: 12) {
                    Text("Icon Only").captionStyle()
                    HStack(spacing: 8) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            ExerciseTypeBadge(type: type, style: .iconOnly)
                        }
                    }
                }
                
                // Pill badges
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pill").captionStyle()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExerciseType.allCases, id: \.self) { type in
                                ExerciseTypeBadge(type: type, style: .pill)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Type Picker") {
    struct PreviewWrapper: View {
        @State var selectedType: ExerciseType = .drill
        
        var body: some View {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ExerciseTypePicker(selectedType: $selectedType)
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
