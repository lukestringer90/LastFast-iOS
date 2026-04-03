// SetGoalPage.swift
// LastFast

import SwiftUI

struct SetGoalPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "target",
            iconColor: .blue,
            title: "Set Your Goal",
            description: "Tap the large time display to choose your fasting duration — pick hours and minutes, or set a specific end time."
        ) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 6) {
                    Text("FAST GOAL")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .tracking(1)

                    Text("16h")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)

                    Text("Ends: 08:00")
                        .font(.subheadline)
                        .foregroundStyle(.blue.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .cardBackground()

                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }
}

#Preview {
    SetGoalPage()
}
