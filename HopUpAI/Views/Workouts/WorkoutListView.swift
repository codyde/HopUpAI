//
//  WorkoutListView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// List of all workouts with creation
struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Workout.createdAt, order: .reverse) private var workouts: [Workout]
    
    @State private var showingNewWorkout = false
    @State private var searchText = ""
    
    private var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workouts
        }
        return workouts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if workouts.isEmpty {
                    emptyState
                } else {
                    workoutList
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search workouts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.basketball)
                    }
                }
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewWorkoutView()
            }
        }
    }
    
    // MARK: - Workout List
    
    private var workoutList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredWorkouts.enumerated()), id: \.element.id) { index, workout in
                    NavigationLink {
                        WorkoutDetailView(workout: workout)
                    } label: {
                        WorkoutRowView(workout: workout)
                    }
                    .buttonStyle(CardPressStyle())
                    .staggeredAppearance(index: index)
                }
            }
            .padding()
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "clipboard",
                title: "No Workouts Yet",
                message: "Build a workout by combining your exercises",
                actionTitle: "Create Workout"
            ) {
                showingNewWorkout = true
            }
            Spacer()
        }
    }
}

// MARK: - Workout Row View

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    if let description = workout.workoutDescription, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            
            // Stats row
            HStack(spacing: 16) {
                // Exercise count
                Label(workout.exerciseCountText, systemImage: "figure.basketball")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                
                // Duration estimate
                Label(workout.durationText, systemImage: "clock")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                
                Spacer()
                
                // Completion count
                if workout.completionCount > 0 {
                    Label("\(workout.completionCount)×", systemImage: "checkmark.circle")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.success)
                }
            }
            
            // Exercise type summary
            if !workout.exerciseTypeSummary.isEmpty {
                HStack(spacing: 8) {
                    ForEach(Array(workout.exerciseTypeSummary.keys.sorted()), id: \.self) { type in
                        if let count = workout.exerciseTypeSummary[type] {
                            ExerciseTypeBadge(type: type, style: .compact)
                                .overlay(
                                    Text("\(count)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textPrimary)
                                        .padding(4)
                                        .background(AppColors.court)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8),
                                    alignment: .topTrailing
                                )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    WorkoutListView()
        .modelContainer(for: [Workout.self, Exercise.self, WorkoutExercise.self], inMemory: true)
}
