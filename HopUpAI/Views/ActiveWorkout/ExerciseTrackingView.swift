//
//  ExerciseTrackingView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI

/// View for tracking current exercise during active workout
struct ExerciseTrackingView: View {
    let workoutExercise: WorkoutExercise
    let currentSet: Int
    let onComplete: () -> Void
    
    @State private var isPressed = false
    
    private var exercise: Exercise? {
        workoutExercise.exercise
    }
    
    private var isLastSet: Bool {
        currentSet >= workoutExercise.sets
    }
    
    private var setLabel: String {
        exercise?.type == .cardio ? "Round" : "Set"
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Exercise info card
            exerciseInfoCard
            
            // Set/round progress
            setProgressIndicator
            
            // Complete button
            completeButton
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Exercise Info Card
    
    private var exerciseInfoCard: some View {
        VStack(spacing: 20) {
            // Type badge
            if let exercise = exercise {
                ExerciseTypeBadge(type: exercise.type, style: .pill)
            }
            
            // Exercise name
            Text(exercise?.name ?? "Unknown Exercise")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Description
            if let description = exercise?.exerciseDescription, !description.isEmpty {
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Target info
            targetInfoSection
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Target Info
    
    private var targetInfoSection: some View {
        HStack(spacing: 32) {
            // Reps or duration
            if let exercise = exercise {
                if exercise.type.usesReps {
                    VStack(spacing: 4) {
                        Text("\(workoutExercise.reps)")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.basketball)
                        
                        Text("reps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                if exercise.type.usesDuration, let duration = workoutExercise.duration {
                    VStack(spacing: 4) {
                        Text(formatDuration(duration))
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.basketball)
                        
                        Text("duration")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                
                if exercise.type.usesWeight, let weight = workoutExercise.weight {
                    VStack(spacing: 4) {
                        Text("\(Int(weight))")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(AppColors.gold)
                        
                        Text("lbs")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Set Progress Indicator
    
    private var setProgressIndicator: some View {
        VStack(spacing: 12) {
            // Set dots
            HStack(spacing: 8) {
                ForEach(1...workoutExercise.sets, id: \.self) { set in
                    Circle()
                        .fill(
                            set < currentSet
                                ? AppColors.success
                                : set == currentSet
                                    ? AppColors.basketball
                                    : AppColors.courtLines
                        )
                        .frame(width: set == currentSet ? 14 : 10, height: set == currentSet ? 14 : 10)
                        .animation(AppAnimations.bouncy, value: currentSet)
                }
            }
            
            // Set label
            Text("\(setLabel) \(currentSet) of \(workoutExercise.sets)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    
    // MARK: - Complete Button
    
    private var completeButton: some View {
        Button {
            onComplete()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isLastSet ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 24))
                
                Text(isLastSet ? "Complete Exercise" : "Complete \(setLabel)")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                isLastSet
                    ? AppColors.success
                    : AppColors.basketball
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: (isLastSet ? AppColors.success : AppColors.basketball).opacity(0.4),
                radius: 12,
                y: 4
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(AppAnimations.snappy) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(AppAnimations.snappy) {
                        isPressed = false
                    }
                }
        )
    }
    
    // MARK: - Helpers
    
    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds > 0 {
                return "\(minutes):\(String(format: "%02d", remainingSeconds))"
            }
            return "\(minutes) min"
        }
        return "\(seconds)s"
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        ExerciseTrackingView(
            workoutExercise: WorkoutExercise(
                exercise: Exercise(name: "Free Throws", type: .drill, defaultSets: 4, defaultReps: 10),
                workout: Workout(name: "Test"),
                sortOrder: 0
            ),
            currentSet: 2,
            onComplete: {}
        )
    }
}
