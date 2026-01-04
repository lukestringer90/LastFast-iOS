//
//  GoalPickerView.swift
//  LastFast
//
//  View for selecting fasting goal duration
//

import SwiftUI

// MARK: - Goal Picker View

struct GoalPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goalMinutes: Int
    
    @State private var selectedHours: Int = 8
    @State private var selectedMinutes: Int = 0
    
    private var isValidGoal: Bool {
        selectedHours > 0 || selectedMinutes > 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Set Your Fasting Goal")
                    .font(.headline)
                    .padding(.top, 24)
                
                hoursStepperSection
                minutesStepperSection
                totalDisplaySection
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        goalMinutes = selectedHours * 60 + selectedMinutes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidGoal)
                }
            }
            .onAppear {
                selectedHours = goalMinutes / 60
                selectedMinutes = goalMinutes % 60
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Subviews
    
    private var hoursStepperSection: some View {
        VStack(spacing: 8) {
            Text("Hours")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Stepper(value: $selectedHours, in: 0...47) {
                Text("\(selectedHours)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var minutesStepperSection: some View {
        VStack(spacing: 8) {
            Text("Minutes")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Stepper(value: $selectedMinutes, in: 0...59) {
                Text("\(selectedMinutes)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var totalDisplaySection: some View {
        Group {
            if isValidGoal {
                Text("Total: \(formatDuration(hours: selectedHours, minutes: selectedMinutes))")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            } else {
                Text("Goal must be at least 1 minute")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GoalPickerView(goalMinutes: .constant(480))
}
