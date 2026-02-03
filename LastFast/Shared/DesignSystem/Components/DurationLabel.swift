//
//  DurationLabel.swift
//  LastFast
//
//  Reusable component for displaying formatted durations
//

import SwiftUI

// MARK: - Duration Label

struct DurationLabel: View {
    let duration: TimeInterval
    let goalMet: Bool?
    var hasGoal: Bool = true
    var font: Font = .system(.title3, design: .rounded)
    var fontWeight: Font.Weight = .semibold

    private var color: Color {
        guard let met = goalMet else {
            return GoalStatusColors.durationColor(goalMet: false, hasGoal: hasGoal)
        }
        return GoalStatusColors.durationColor(goalMet: met, hasGoal: hasGoal)
    }

    var body: some View {
        Text(formatDuration(from: duration))
            .font(font)
            .fontWeight(fontWeight)
            .foregroundStyle(color)
    }
}

// MARK: - Preview

#Preview("Goal Met") {
    DurationLabel(duration: 16 * 3600, goalMet: true)
}

#Preview("Goal Not Met") {
    DurationLabel(duration: 8 * 3600, goalMet: false)
}

#Preview("No Goal") {
    DurationLabel(duration: 8 * 3600, goalMet: nil, hasGoal: false)
}
