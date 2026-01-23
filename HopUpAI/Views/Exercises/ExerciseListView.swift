//
//  ExerciseListView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// List of all exercises with filtering and creation
struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.createdAt, order: .reverse) private var exercises: [Exercise]
    
    @State private var showingNewExercise = false
    @State private var selectedTypes: Set<ExerciseType> = Set(ExerciseType.allCases)
    @State private var searchText = ""
    
    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesType = selectedTypes.contains(exercise.type)
            let matchesSearch = searchText.isEmpty || 
                exercise.name.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }
    
    private var groupedExercises: [(ExerciseType, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.type }
        return ExerciseType.allCases
            .compactMap { type -> (ExerciseType, [Exercise])? in
                guard let exercises = grouped[type], !exercises.isEmpty else { return nil }
                return (type, exercises)
            }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type filter
                ExerciseTypeFilter(selectedTypes: $selectedTypes)
                    .padding(.vertical, 12)
                
                // Exercise list
                if filteredExercises.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    exerciseList
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewExercise = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.basketball)
                    }
                }
            }
            .sheet(isPresented: $showingNewExercise) {
                NewExerciseView()
            }
        }
    }
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        ScrollView {
            LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                ForEach(groupedExercises, id: \.0) { type, typeExercises in
                    Section {
                        VStack(spacing: 12) {
                            ForEach(Array(typeExercises.enumerated()), id: \.element.id) { index, exercise in
                                ExerciseRowView(exercise: exercise)
                                    .staggeredAppearance(index: index)
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        sectionHeader(for: type, count: typeExercises.count)
                    }
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(for type: ExerciseType, count: Int) -> some View {
        HStack {
            Image(systemName: type.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(type.color)
            
            Text(type.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(type.color)
            
            Text("(\(count))")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(AppColors.background)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack {
            if exercises.isEmpty {
                EmptyStateView(
                    icon: "figure.basketball",
                    title: "No Exercises Yet",
                    message: "Create your first exercise to start building workouts",
                    actionTitle: "Create Exercise"
                ) {
                    showingNewExercise = true
                }
            } else {
                // Filter returned no results
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "No exercises match your current filters"
                )
            }
        }
    }
}

// MARK: - Exercise Row View

struct ExerciseRowView: View {
    let exercise: Exercise
    @Environment(\.modelContext) private var modelContext
    @State private var showingDetail = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            HStack(spacing: 16) {
                // Type indicator
                ExerciseTypeBadge(type: exercise.type, style: .iconOnly)
                
                // Exercise info
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(exercise.defaultConfigurationText)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(16)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(CardPressStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation(AppAnimations.standard) {
                    modelContext.delete(exercise)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingDetail) {
            ExerciseDetailView(exercise: exercise)
        }
    }
}

// MARK: - Exercise Detail View

struct ExerciseDetailView: View {
    @Bindable var exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Type badge
                    ExerciseTypeBadge(type: exercise.type, style: .pill)
                    
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("Exercise name", text: $exercise.name)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(16)
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField(
                            "Exercise description",
                            text: Binding(
                                get: { exercise.exerciseDescription ?? "" },
                                set: { exercise.exerciseDescription = $0.isEmpty ? nil : $0 }
                            ),
                            axis: .vertical
                        )
                        .lineLimit(3...6)
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                        .padding(16)
                        .background(AppColors.court)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Configuration
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Configuration")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        exerciseConfigFields
                    }
                    
                    // Delete button
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Exercise")
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
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.basketball)
                }
            }
            .alert("Delete Exercise?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    modelContext.delete(exercise)
                    dismiss()
                }
            } message: {
                Text("This will permanently delete \"\(exercise.name)\" and remove it from any workouts.")
            }
        }
    }
    
    @ViewBuilder
    private var exerciseConfigFields: some View {
        VStack(spacing: 12) {
            // Sets
            HStack {
                Text("Sets")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                Stepper(
                    "\(exercise.defaultSets)",
                    value: $exercise.defaultSets,
                    in: 1...20
                )
                .labelsHidden()
                
                Text("\(exercise.defaultSets)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.basketball)
                    .frame(width: 40)
            }
            .padding(16)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Reps (if applicable)
            if exercise.type.usesReps {
                HStack {
                    Text("Reps")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Stepper(
                        "\(exercise.defaultReps)",
                        value: $exercise.defaultReps,
                        in: 1...100
                    )
                    .labelsHidden()
                    
                    Text("\(exercise.defaultReps)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.basketball)
                        .frame(width: 40)
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Weight (if applicable)
            if exercise.type.usesWeight {
                HStack {
                    Text("Weight (lbs)")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    TextField(
                        "0",
                        value: $exercise.defaultWeight,
                        format: .number
                    )
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.basketball)
                    .frame(width: 80)
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Duration (if applicable)
            if exercise.type.usesDuration {
                HStack {
                    Text("Duration (sec)")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    TextField(
                        "0",
                        value: $exercise.defaultDuration,
                        format: .number
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.basketball)
                    .frame(width: 80)
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    ExerciseListView()
        .modelContainer(for: [Exercise.self, Workout.self], inMemory: true)
}
