//
//  NewExerciseView.swift
//  HopUpAI
//
//  Created by Cody De Arkland on 1/14/26.
//

import SwiftUI
import SwiftData

/// Sheet view for creating a new exercise
struct NewExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var type: ExerciseType = .drill
    @State private var sets = 3
    @State private var reps = 10
    @State private var weight: Double? = nil
    @State private var duration: Int? = nil
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, description
    }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
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
                        
                        TextField("Exercise name", text: $name)
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
                        
                        TextField("Exercise description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(size: 15))
                            .foregroundStyle(AppColors.textPrimary)
                            .padding(16)
                            .background(AppColors.court)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focusedField, equals: .description)
                    }
                    
                    // Exercise type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Type")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        ExerciseTypePicker(selectedType: $type)
                    }
                    
                    // Configuration section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Configuration")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                        
                        configurationFields
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("New Exercise")
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
                        createExercise()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? AppColors.basketball : AppColors.textTertiary)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                focusedField = .name
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Configuration Fields
    
    private var configurationFields: some View {
        VStack(spacing: 12) {
            // Sets stepper
            HStack {
                Label("Sets", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        if sets > 1 { sets -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    Text("\(sets)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.basketball)
                        .frame(width: 40)
                    
                    Button {
                        if sets < 20 { sets += 1 }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.basketball)
                    }
                }
            }
            .padding(16)
            .background(AppColors.court)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Reps stepper (for rep-based exercises)
            if type.usesReps {
                HStack {
                    Label("Reps", systemImage: "repeat")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button {
                            if reps > 1 { reps -= 1 }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                        
                        Text("\(reps)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.basketball)
                            .frame(width: 40)
                        
                        Button {
                            if reps < 100 { reps += 5 }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.basketball)
                        }
                    }
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Weight field (for weight-based exercises)
            if type.usesWeight {
                HStack {
                    Label("Weight (lbs)", systemImage: "scalemass")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    TextField("0", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.basketball)
                        .frame(width: 80)
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Duration field (for cardio exercises)
            if type.usesDuration {
                HStack {
                    Label("Duration (sec)", systemImage: "timer")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    TextField("60", value: $duration, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.basketball)
                        .frame(width: 80)
                }
                .padding(16)
                .background(AppColors.court)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(AppAnimations.standard, value: type)
    }
    
    // MARK: - Actions
    
    private func createExercise() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let exercise = Exercise(
            name: trimmedName,
            exerciseDescription: description.isEmpty ? nil : description,
            type: type,
            defaultSets: sets,
            defaultReps: reps,
            defaultWeight: type.usesWeight ? weight : nil,
            defaultDuration: type.usesDuration ? duration : nil
        )
        
        modelContext.insert(exercise)
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    NewExerciseView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
