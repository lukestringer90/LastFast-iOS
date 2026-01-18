//
//  GoalSetterView.swift
//  LastFast
//
//  View for displaying and selecting fasting goal before starting
//

import SwiftUI

struct GoalSetterView: View {
    let savedGoalMinutes: Int
    let currentTime: Date
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("Goal: \(formatDuration(hours: savedGoalMinutes / 60, minutes: savedGoalMinutes % 60))")
                    .font(.headline)
                    .foregroundStyle(.primary)

                let estimatedFinish = currentTime.addingTimeInterval(TimeInterval(savedGoalMinutes * 60))
                Text("Finish at \(format24HourTime(estimatedFinish))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Tap to change")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
}

// MARK: - Preview

#Preview {
    GoalSetterView(
        savedGoalMinutes: 720,
        currentTime: Date(),
        onTap: {}
    )
}
