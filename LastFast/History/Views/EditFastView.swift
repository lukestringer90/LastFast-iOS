//
//  EditFastView.swift
//  LastFast
//
//  View for editing the details of a completed fast
//

import SwiftUI
import SwiftData

// MARK: - Edit Fast View

struct EditFastView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let session: FastingSession

    @State private var startTime: Date
    @State private var endTime: Date
    @State private var goalHours: Int
    @State private var goalMinutes: Int

    init(session: FastingSession) {
        self.session = session
        _startTime = State(initialValue: session.startTime)
        _endTime = State(initialValue: session.endTime ?? Date())

        let goal = session.goalMinutes ?? defaultFastingGoalMinutes
        _goalHours = State(initialValue: goal / 60)
        _goalMinutes = State(initialValue: goal % 60)
    }

    private var goalTotalMinutes: Int {
        goalHours * 60 + goalMinutes
    }

    private var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    private var isValid: Bool {
        endTime > startTime && goalTotalMinutes > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Start Time",
                        selection: $startTime,
                        in: ...endTime
                    )

                    DatePicker(
                        "End Time",
                        selection: $endTime,
                        in: startTime...
                    )
                } header: {
                    Text("Time")
                }

                Section {
                    HStack {
                        Text("Goal")
                        Spacer()
                        Picker("Hours", selection: $goalHours) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)h").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()

                        Picker("Minutes", selection: $goalMinutes) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)m").tag(minute)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                } header: {
                    Text("Goal")
                }

                Section {
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(formatDuration(from: duration))
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Goal Met")
                        Spacer()
                        let goalMet = Int(duration) / 60 >= goalTotalMinutes
                        Image(systemName: goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(goalMet ? .green : .red)
                    }
                } header: {
                    Text("Summary")
                }
            }
            .navigationTitle("Edit Fast")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func saveChanges() {
        session.startTime = startTime
        session.endTime = endTime
        session.goalMinutes = goalTotalMinutes

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    EditFastView(session: {
        let session = FastingSession(
            startTime: Date().addingTimeInterval(-57600),
            goalMinutes: defaultFastingGoalMinutes
        )
        session.endTime = Date()
        return session
    }())
    .modelContainer(for: FastingSession.self, inMemory: true)
}
