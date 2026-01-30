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

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Time display matching TimerDisplayView style
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(hours)")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)

                    Text("h")
                        .font(.system(size: 36, weight: .medium, design: .rounded))
                        .foregroundStyle(.blue.opacity(0.7))

                    if minutes > 0 {
                        Text("\(minutes)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundStyle(.blue)

                        Text("m")
                            .font(.system(size: 36, weight: .medium, design: .rounded))
                            .foregroundStyle(.blue.opacity(0.7))
                    }
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)

                // "Fast Goal" label underneath
                Text("Fast Goal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GoalSetterView(
        savedGoalMinutes: 720,
        onTap: {}
    )
}
