//
//  ActiveWorkoutView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Main view for an active workout session
struct ActiveWorkoutView: View {
    let workout: Workout
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    // Workout state
    @State private var session: WorkoutSession?
    @State private var currentExerciseIndex = 0
    @State private var currentSetIndex = 0
    @State private var completedSets: [UUID: Int] = [:] // exerciseId -> sets completed
    
    // Timer state
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isRunning = true
    
    // XP tracking
    @State private var totalXPEarned = 0
    @State private var showingXPGain = false
    @State private var lastXPGain = 0
    
    // UI state
    @State private var showingEndConfirmation = false
    @State private var showingCompletion = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var exercises: [WorkoutExercise] {
        workout.sortedExercises
    }
    
    private var currentExercise: WorkoutExercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    private var isWorkoutComplete: Bool {
        currentExerciseIndex >= exercises.count
    }
    
    private var progressPercentage: Double {
        guard !exercises.isEmpty else { return 0 }
        let totalSets = exercises.reduce(0) { $0 + $1.sets }
        let completedTotal = completedSets.values.reduce(0, +)
        return Double(completedTotal) / Double(totalSets)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with timer and progress
                headerSection
                
                // Current exercise
                if let exercise = currentExercise {
                    ExerciseTrackingView(
                        workoutExercise: exercise,
                        currentSet: currentSetIndex + 1,
                        onComplete: completeCurrentSet
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(exercise.id)
                } else {
                    Spacer()
                }
                
                Spacer()
                
                // End workout button
                endWorkoutButton
            }
            
            // XP gain animation
            if showingXPGain {
                XPGainView(amount: lastXPGain)
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showingEndConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .alert("End Workout?", isPresented: $showingEndConfirmation) {
            Button("Continue Workout", role: .cancel) { }
            Button("End Without XP", role: .destructive) {
                endWorkoutEarly()
            }
        } message: {
            Text("You won't earn any XP if you end the workout early.")
        }
        .fullScreenCover(isPresented: $showingCompletion) {
            WorkoutCompleteView(
                workout: workout,
                session: session,
                totalXP: totalXPEarned,
                duration: elapsedTime,
                onDismiss: {
                    dismiss()
                }
            )
        }
        .onAppear {
            startWorkout()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Workout name
            Text(workout.name)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
            
            // Timer
            HStack(spacing: 24) {
                // Elapsed time
                VStack(spacing: 4) {
                    Text(formatTime(elapsedTime))
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text("Elapsed")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                // XP earned
                VStack(spacing: 4) {
                    Text("+\(totalXPEarned)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.basketball)
                    
                    Text("XP")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.courtLines)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(AppColors.basketballGradient)
                            .frame(width: geometry.size.width * progressPercentage)
                            .animation(AppAnimations.bouncy, value: progressPercentage)
                    }
                }
                .frame(height: 8)
                
                // Exercise progress
                HStack {
                    Text("Exercise \(min(currentExerciseIndex + 1, exercises.count)) of \(exercises.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage * 100))% complete")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.basketball)
                }
            }
        }
        .padding(20)
        .background(AppColors.court)
    }
    
    // MARK: - End Workout Button
    
    private var endWorkoutButton: some View {
        Button {
            showingEndConfirmation = true
        } label: {
            Text("End Workout")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.error)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.error.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
    
    // MARK: - Timer Functions
    
    private func startWorkout() {
        // Create session
        let newSession = WorkoutSession(workout: workout)
        modelContext.insert(newSession)
        session = newSession
        
        // Initialize completed sets tracking
        for exercise in exercises {
            completedSets[exercise.id] = 0
        }
        
        // Start timer
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if isRunning {
                elapsedTime += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Workout Logic
    
    private func completeCurrentSet() {
        guard let exercise = currentExercise else { return }
        
        // Calculate XP for this set/round
        let streakMultiplier = profile?.streakMultiplier ?? 1.0
        let setXP = XPService.xpForRounds(1, streakMultiplier: streakMultiplier)
        
        // Award XP
        awardXP(setXP)
        
        // Update completed sets
        let currentCompleted = completedSets[exercise.id] ?? 0
        completedSets[exercise.id] = currentCompleted + 1
        currentSetIndex += 1
        
        // Check if exercise is complete
        if currentSetIndex >= exercise.sets {
            completeCurrentExercise()
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    private func completeCurrentExercise() {
        guard let exercise = currentExercise else { return }
        
        // Award exercise completion bonus
        let streakMultiplier = profile?.streakMultiplier ?? 1.0
        let bonusXP = Int(Double(XPService.xpExerciseBonus) * streakMultiplier)
        awardXP(bonusXP)
        
        // Log the exercise
        if let session = session, let exerciseModel = exercise.exercise {
            let log = ExerciseLog(
                exercise: exerciseModel,
                session: session,
                targetRounds: exercise.sets,
                weightUsed: exercise.weight
            )
            log.roundsCompleted = exercise.sets
            log.xpEarned = (completedSets[exercise.id] ?? 0) * XPService.xpPerRound + bonusXP
            log.complete()
            modelContext.insert(log)
        }
        
        // Move to next exercise
        withAnimation(AppAnimations.standard) {
            currentExerciseIndex += 1
            currentSetIndex = 0
        }
        
        // Check if workout is complete
        if isWorkoutComplete {
            completeWorkout()
        }
        
        // Success haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func completeWorkout() {
        stopTimer()
        
        // Award workout completion bonus
        let streakMultiplier = profile?.streakMultiplier ?? 1.0
        let workoutBonusXP = Int(Double(XPService.xpWorkoutBonus) * streakMultiplier)
        awardXP(workoutBonusXP)
        
        // Update session
        session?.complete()
        session?.totalXPEarned = totalXPEarned
        
        // Update profile
        if let profile = profile {
            let result = profile.addXP(totalXPEarned)
            profile.updateStreak()
            profile.totalWorkoutsCompleted += 1
        }
        
        // Show completion screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showingCompletion = true
        }
    }
    
    private func endWorkoutEarly() {
        stopTimer()
        
        // Delete the session (no XP awarded)
        if let session = session {
            modelContext.delete(session)
        }
        
        dismiss()
    }
    
    private func awardXP(_ amount: Int) {
        totalXPEarned += amount
        lastXPGain = amount
        
        withAnimation(AppAnimations.bouncy) {
            showingXPGain = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingXPGain = false
        }
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(workout: Workout(name: "Test Workout"))
    }
    .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self, WorkoutSession.self, ExerciseLog.self, UserProfile.self], inMemory: true)
}
