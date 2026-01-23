//
//  NewWorkoutView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Sheet view for creating a new workout
struct NewWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.name) private var allExercises: [Exercise]
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedExercises: [SelectedExercise] = []
    @State private var showingExercisePicker = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !selectedExercises.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("Workout name", text: $name)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(16)
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        focusedField == .name 
                                            ? AppColors.basketball.opacity(0.5) 
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            .focused($focusedField, equals: .name)
                    }
                    
                    // Description field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description (optional)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("Workout description", text: $description, axis: .vertical)
                            .lineLimit(2...4)
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(16)
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focusedField, equals: .description)
                    }
                    
                    // Selected exercises
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Exercises")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Button {
                                showingExercisePicker = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.basketball)
                            }
                        }
                        
                        if selectedExercises.isEmpty {
                            CompactEmptyState(
                                icon: "plus.circle",
                                message: "Add exercises to build your workout"
                            )
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            exercisesList
                        }
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createWorkout()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? AppColors.basketball : AppColors.textTertiary)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView(
                    allExercises: allExercises,
                    selectedExercises: $selectedExercises
                )
            }
            .onAppear {
                focusedField = .name
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Exercises List
    
    private var exercisesList: some View {
        VStack(spacing: 8) {
            ForEach(Array(selectedExercises.enumerated()), id: \.element.id) { index, selected in
                SelectedExerciseRow(
                    selected: binding(for: selected),
                    index: index + 1,
                    onDelete: {
                        withAnimation(AppAnimations.standard) {
                            selectedExercises.removeAll { $0.id == selected.id }
                        }
                    },
                    onMoveUp: index > 0 ? {
                        withAnimation(AppAnimations.standard) {
                            selectedExercises.swapAt(index, index - 1)
                        }
                    } : nil,
                    onMoveDown: index < selectedExercises.count - 1 ? {
                        withAnimation(AppAnimations.standard) {
                            selectedExercises.swapAt(index, index + 1)
                        }
                    } : nil
                )
            }
        }
    }
    
    private func binding(for selected: SelectedExercise) -> Binding<SelectedExercise> {
        guard let index = selectedExercises.firstIndex(where: { $0.id == selected.id }) else {
            return .constant(selected)
        }
        return $selectedExercises[index]
    }
    
    // MARK: - Actions
    
    private func createWorkout() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !selectedExercises.isEmpty else { return }
        
        let workout = Workout(
            name: trimmedName,
            workoutDescription: description.isEmpty ? nil : description
        )
        
        modelContext.insert(workout)
        
        // Create workout exercises
        for (index, selected) in selectedExercises.enumerated() {
            let workoutExercise = WorkoutExercise(
                exercise: selected.exercise,
                workout: workout,
                sortOrder: index,
                sets: selected.sets,
                reps: selected.reps,
                weight: selected.weight,
                duration: selected.duration
            )
            modelContext.insert(workoutExercise)
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Supporting Types

/// Represents a selected exercise with customizations
struct SelectedExercise: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: Int
    var reps: Int
    var weight: Double?
    var duration: Int?
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self.sets = exercise.defaultSets
        self.reps = exercise.defaultReps
        self.weight = exercise.defaultWeight
        self.duration = exercise.defaultDuration
    }
}

/// Row for a selected exercise in new workout view
struct SelectedExerciseRow: View {
    @Binding var selected: SelectedExercise
    let index: Int
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 12) {
                // Order number
                Text("\(index)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.basketball)
                    .frame(width: 24, height: 24)
                    .background(AppColors.basketball.opacity(0.15))
                    .clipShape(Circle())
                
                // Exercise info
                VStack(alignment: .leading, spacing: 2) {
                    Text(selected.exercise.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(selected.sets) × \(selected.reps) reps")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Type badge
                ExerciseTypeBadge(type: selected.exercise.type, style: .iconOnly)
                
                // Expand/collapse
                Button {
                    withAnimation(AppAnimations.standard) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 28, height: 28)
                        .background(AppColors.courtLines)
                        .clipShape(Circle())
                }
            }
            .padding(12)
            
            // Expanded controls
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(AppColors.courtLines)
                    
                    // Sets/reps controls
                    HStack(spacing: 24) {
                        // Sets
                        VStack(spacing: 4) {
                            Text("Sets")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                            
                            HStack(spacing: 8) {
                                Button {
                                    if selected.sets > 1 { selected.sets -= 1 }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.textSecondary)
                                        .frame(width: 24, height: 24)
                                        .background(AppColors.courtLines)
                                        .clipShape(Circle())
                                }
                                
                                Text("\(selected.sets)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppColors.basketball)
                                    .frame(width: 30)
                                
                                Button {
                                    if selected.sets < 20 { selected.sets += 1 }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.basketball)
                                        .frame(width: 24, height: 24)
                                        .background(AppColors.basketball.opacity(0.15))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        
                        // Reps
                        if selected.exercise.type.usesReps {
                            VStack(spacing: 4) {
                                Text("Reps")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(AppColors.textSecondary)
                                
                                HStack(spacing: 8) {
                                    Button {
                                        if selected.reps > 1 { selected.reps -= 1 }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(AppColors.textSecondary)
                                            .frame(width: 24, height: 24)
                                            .background(AppColors.courtLines)
                                            .clipShape(Circle())
                                    }
                                    
                                    Text("\(selected.reps)")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppColors.basketball)
                                        .frame(width: 30)
                                    
                                    Button {
                                        if selected.reps < 100 { selected.reps += 5 }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(AppColors.basketball)
                                            .frame(width: 24, height: 24)
                                            .background(AppColors.basketball.opacity(0.15))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    // Reorder and delete buttons
                    HStack(spacing: 12) {
                        if let onMoveUp = onMoveUp {
                            Button(action: onMoveUp) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        
                        if let onMoveDown = onMoveDown {
                            Button(action: onMoveDown) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: onDelete) {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.error)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            }
        }
        .background(AppColors.court)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Exercise Picker View

struct ExercisePickerView: View {
    let allExercises: [Exercise]
    @Binding var selectedExercises: [SelectedExercise]
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedTypes: Set<ExerciseType> = Set(ExerciseType.allCases)
    
    private var filteredExercises: [Exercise] {
        allExercises.filter { exercise in
            let matchesType = selectedTypes.contains(exercise.type)
            let matchesSearch = searchText.isEmpty || 
                exercise.name.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }
    
    private var alreadySelectedIds: Set<UUID> {
        Set(selectedExercises.map { $0.exercise.id })
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type filter
                ExerciseTypeFilter(selectedTypes: $selectedTypes)
                    .padding(.vertical, 12)
                
                // Exercise list
                if allExercises.isEmpty {
                    emptyState
                } else {
                    exerciseList
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
    
    private var exerciseList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredExercises) { exercise in
                    let isSelected = alreadySelectedIds.contains(exercise.id)
                    
                    Button {
                        if !isSelected {
                            withAnimation(AppAnimations.standard) {
                                selectedExercises.append(SelectedExercise(exercise: exercise))
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
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
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColors.success)
                            } else {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(AppColors.basketball)
                            }
                        }
                        .padding(16)
                        .background(isSelected ? AppColors.success.opacity(0.1) : AppColors.court)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(HopUpButtonStyle())
                    .disabled(isSelected)
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "figure.basketball",
                title: "No Exercises",
                message: "Create some exercises first, then add them to your workout"
            )
            Spacer()
        }
    }
}

#Preview {
    NewWorkoutView()
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutExercise.self], inMemory: true)
}
