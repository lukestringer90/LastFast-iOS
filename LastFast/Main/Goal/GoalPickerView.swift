//
//  GoalPickerView.swift
//  LastFast
//
//  View for selecting fasting goal duration or end time
//

import SwiftUI
import FirebaseAnalytics // Added for AnalyticsManager
import Foundation // Already exists for `Date` and `TimeInterval`
import AppTrackingTransparency // For AnalyticsManager.swift

// MARK: - Goal Picker View

struct GoalPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goalMinutes: Int

    @State private var goalMode: GoalMode = .duration
    @State private var selectedHours: Int = 8
    @State private var selectedMinutes: Int = 0
    @State private var selectedEndTime: Date = Date().addingTimeInterval(8 * 3600)

    private var minutesUntilEndTime: Int {
        calculateMinutesUntilEndTime(selectedEndTime)
    }

    private var isValidGoal: Bool {
        isGoalValid(
            mode: goalMode,
            selectedHours: selectedHours,
            selectedMinutes: selectedMinutes,
            minutesUntilEndTime: minutesUntilEndTime
        )
    }

    private var computedGoalMinutes: Int {
        computeGoalMinutes(
            mode: goalMode,
            selectedHours: selectedHours,
            selectedMinutes: selectedMinutes,
            minutesUntilEndTime: minutesUntilEndTime
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Set Your Fasting Goal")
                    .font(.headline)
                    .padding(.top, 24)
                
                // Mode picker
                Picker("Goal Mode", selection: $goalMode) {
                    ForEach(GoalMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                if goalMode == .duration {
                    durationPickerSection
                } else {
                    endTimePickerSection
                }
                
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
                        goalMinutes = computedGoalMinutes
                        
                        var parameters: [String: Any] = ["goal_minutes": computedGoalMinutes]
                        parameters["goal_mode"] = goalMode.rawValue
                        if goalMode == .duration {
                            parameters["selected_hours"] = selectedHours
                            parameters["selected_minutes"] = selectedMinutes
                        } else {
                            parameters["selected_end_time"] = selectedEndTime.timeIntervalSince1970
                        }
                        AnalyticsManager.logEvent("set_fast_goal", parameters: parameters)
                        
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidGoal)
                }
            }
            .onAppear {
                selectedHours = hoursFromMinutes(goalMinutes)
                selectedMinutes = minutesComponent(goalMinutes)
                selectedEndTime = Date().addingTimeInterval(TimeInterval(goalMinutes * 60))
            }
            .onChange(of: goalMode) { _, newMode in
                // Sync values when switching modes
                if newMode == .endTime {
                    let currentGoal = selectedHours * 60 + selectedMinutes
                    selectedEndTime = Date().addingTimeInterval(TimeInterval(currentGoal * 60))
                } else {
                    let minutes = minutesUntilEndTime
                    selectedHours = hoursFromMinutes(minutes)
                    selectedMinutes = minutesComponent(minutes)
                }
                AnalyticsManager.logEvent("goal_mode_selected", parameters: ["mode": newMode.rawValue])
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Duration Picker Section
    
    private var durationPickerSection: some View {
        VStack(spacing: 24) {
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
    }
    
    // MARK: - End Time Picker Section
    
    private var endTimePickerSection: some View {
        VStack(spacing: 16) {
            Text("Fast until")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            DatePicker(
                "End Time",
                selection: $selectedEndTime,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Total Display Section
    
    private var totalDisplaySection: some View {
        Group {
            if isValidGoal {
                let hours = hoursFromMinutes(computedGoalMinutes)
                let mins = minutesComponent(computedGoalMinutes)
                VStack(spacing: 4) {
                    Text("Total: \(formatDuration(hours: hours, minutes: mins))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    if goalMode == .duration {
                        let endTime = Date().addingTimeInterval(TimeInterval(computedGoalMinutes * 60))
                        Text("Ends at \(format24HourTime(endTime))")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.top, 8)
            } else {
                Text(goalMode == .duration ? "Goal must be at least 1 minute" : "End time must be in the future")
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
