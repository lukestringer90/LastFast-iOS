//
//  GoalSetterView.swift
//  LastFast
//
//  View for displaying and selecting fasting goal before starting
//

import SwiftUI

struct GoalSetterView: View {
    let savedGoalMinutes: Int
    var onTap: () -> Void

    private var hours: Int { savedGoalMinutes / 60 }
    private var minutes: Int { savedGoalMinutes % 60 }

    private var endTime: Date {
        Date().addingTimeInterval(TimeInterval(savedGoalMinutes * 60))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // "FAST GOAL" label above
                Text("FAST GOAL")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.secondaryLabel))
                    .accessibilityIdentifier("fastGoalLabel")

                // Time display matching TimerDisplayView style
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(hours)")
                        .largeTimerFont()
                        .foregroundStyle(.blue)

                    Text("h")
                        .unitLabel(color: .blue)

                    if minutes > 0 {
                        Text("\(minutes)")
                            .largeTimerFont()
                            .foregroundStyle(.blue)

                        Text("m")
                            .unitLabel(color: .blue)
                    }
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                // "Ends: <time>" label underneath
                Text("Ends: \(format24HourTime(endTime))")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue.opacity(0.8))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GoalSetterView(
        savedGoalMinutes: defaultFastingGoalMinutes,
        onTap: {}
    )
}
