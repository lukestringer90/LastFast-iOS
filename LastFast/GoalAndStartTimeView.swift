//
//  GoalAndStartTimeView.swift
//  LastFast
//
//  View displaying goal status and time range during active fast
//

import SwiftUI

struct GoalAndStartTimeView: View {
    let goalMet: Bool
    let elapsedHours: Int
    let elapsedMins: Int
    let activeFast: FastingSession?

    var body: some View {
        VStack(spacing: 4) {
            if goalMet {
                Text("Goal reached!")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Text("\(formatDuration(hours: elapsedHours, minutes: elapsedMins)) fasted")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            if let fast = activeFast, let goal = fast.goalMinutes {
                let completionTime = fast.startTime.addingTimeInterval(TimeInterval(goal * 60))
                Text("\(format24HourTime(fast.startTime)) → \(format24HourTime(completionTime))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview("Goal Not Met") {
    GoalAndStartTimeView(
        goalMet: false,
        elapsedHours: 3,
        elapsedMins: 30,
        activeFast: nil
    )
}

#Preview("Goal Met") {
    GoalAndStartTimeView(
        goalMet: true,
        elapsedHours: 12,
        elapsedMins: 0,
        activeFast: nil
    )
}
