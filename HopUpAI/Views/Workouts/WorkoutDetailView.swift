//
//  WorkoutDetailView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Detailed view of a workout showing exercises and allowing editing
struct WorkoutDetailView: View {
    @Bindable var workout: Workout
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingDeleteAlert = false
    @State private var showingAddExercises = false
    @State private var showingActiveWorkout = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header info
                headerSection
                
                // Start workout button
                startWorkoutButton
                
                // Exercise list
                exercisesSection
                
                // Stats section
                if workout.completionCount > 0 {
                    statsSection
                }
                
                // Delete button
                deleteButton
            }
            .padding()
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddExercises = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Workout", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.basketball)
                }
            }
        }
        .alert("Delete Workout?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                modelContext.delete(workout)
                dismiss()
            }
        } message: {
            Text("This will permanently delete \"\(workout.name)\" and all its exercises.")
        }
        .sheet(isPresented: $showingAddExercises) {
            AddExercisesToWorkoutView(workout: workout)
        }
        .fullScreenCover(isPresented: $showingActiveWorkout) {
            NavigationStack {
                ActiveWorkoutView(workout: workout)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Editable name
            TextField("Workout name", text: $workout.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            // Editable description
            TextField(
                "Add a description",
                text: Binding(
                    get: { workout.workoutDescription ?? "" },
                    set: { workout.workoutDescription = $0.isEmpty ? nil : $0 }
                ),
                axis: .vertical
            )
            .lineLimit(2...4)
            .font(.system(size: 15))
            .foregroundStyle(AppColors.textSecondary)
            
            // Stats row
            HStack(spacing: 20) {
                Label(workout.exerciseCountText, systemImage: "figure.basketball")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                
                Label("~\(workout.durationText)", systemImage: "clock")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                
                if workout.completionCount > 0 {
                    Label("\(workout.completionCount) completed", systemImage: "checkmark.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.success)
                }
            }
        }
        .padding(20)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Start Workout Button
    
    private var startWorkoutButton: some View {
        Button {
            showingActiveWorkout = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18))
                Text("Start Workout")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(AppColors.basketballGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: AppColors.basketball.opacity(0.4), radius: 12, y: 4)
        }
        .buttonStyle(HopUpButtonStyle())
    }
    
    // MARK: - Exercises Section
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Exercises")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Button {
                    showingAddExercises = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.basketball)
                }
            }
            
            if workout.sortedExercises.isEmpty {
                CompactEmptyState(
                    icon: "plus.circle",
                    message: "No exercises yet. Add some to get started!"
                )
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(workout.sortedExercises.enumerated()), id: \.element.id) { index, workoutExercise in
                        WorkoutExerciseRow(
                            workoutExercise: workoutExercise,
                            index: index + 1
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("History")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Text("\(workout.completionCount) times")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.success)
                    }
                    
                    Spacer()
                    
                    if let lastCompleted = workout.lastCompletedAt {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Last completed")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            
                            Text(lastCompleted, style: .relative)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
            }
            .padding(20)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("Delete Workout")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(AppColors.error)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(AppColors.error.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 16)
    }
}

// MARK: - Workout Exercise Row

struct WorkoutExerciseRow: View {
    let workoutExercise: WorkoutExercise
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Index
            Text("\(index)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.basketball)
                .frame(width: 28, height: 28)
                .background(AppColors.basketball.opacity(0.15))
                .clipShape(Circle())
            
            // Exercise info
            VStack(alignment: .leading, spacing: 4) {
                Text(workoutExercise.exercise?.name ?? "Unknown")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                Text(workoutExercise.configurationText)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Type badge
            if let exercise = workoutExercise.exercise {
                ExerciseTypeBadge(type: exercise.type, style: .iconOnly)
            }
        }
        .padding(16)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Exercises to Workout View

struct AddExercisesToWorkoutView: View {
    let workout: Workout
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    
    @State private var searchText = ""
    @State private var selectedTypes: Set<ExerciseType> = Set(ExerciseType.allCases)
    
    private var existingExerciseIds: Set<UUID> {
        Set(workout.sortedExercises.compactMap { $0.exercise?.id })
    }
    
    private var filteredExercises: [Exercise] {
        allExercises.filter { exercise in
            let matchesType = selectedTypes.contains(exercise.type)
            let matchesSearch = searchText.isEmpty || 
                exercise.name.localizedCaseInsensitiveContains(searchText)
            let notAlreadyAdded = !existingExerciseIds.contains(exercise.id)
            return matchesType && matchesSearch && notAlreadyAdded
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ExerciseTypeFilter(selectedTypes: $selectedTypes)
                    .padding(.vertical, 12)
                
                if filteredExercises.isEmpty {
                    VStack {
                        Spacer()
                        EmptyStateView(
                            icon: "checkmark.circle",
                            title: "All Done",
                            message: "All available exercises are already in this workout"
                        )
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExercises) { exercise in
                                Button {
                                    addExercise(exercise)
                                } label: {
                                    HStack(spacing: 12) {
                                        ExerciseTypeBadge(type: exercise.type, style: .iconOnly)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(exercise.name)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(AppColors.textPrimary)
                                            
                                            Text(exercise.defaultConfigurationText)
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 20))
                                            .foregroundStyle(AppColors.basketball)
                                    }
                                    .padding(16)
                                    .background(AppColors.court)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(HopUpButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.basketball)
                }
            }
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        let nextOrder = (workout.exercises?.count ?? 0)
        let workoutExercise = WorkoutExercise(
            exercise: exercise,
            workout: workout,
            sortOrder: nextOrder
        )
        modelContext.insert(workoutExercise)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(name: "Morning Warmup", workoutDescription: "Quick routine to start the day"))
    }
    .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self], inMemory: true)
}
