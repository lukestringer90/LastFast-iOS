// WelcomePage.swift
// LastFast

import SwiftUI

struct WelcomePage: View {
    private var endTimeString: String {
        let date = Calendar.current.date(bySettingHour: 10, minute: 30, second: 0, of: Date()) ?? Date()
        return formatTime(date)
    }

    var body: some View {
        OnboardingPageView(
            iconName: "bolt.heart.fill",
            iconColor: .orange,
            imageName: "AppIconDisplay",
            title: "Welcome to Last Fast",
            description: "Track your intermittent fasts and hit your goals. Start by setting how long you want to fast by taping the preset goal."
        ) {
            VStack(spacing: 6) {
                Text("FAST GOAL")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .tracking(1)

                Text("16h")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)

                Text("Ends: \(endTimeString)")
                    .font(.subheadline)
                    .foregroundStyle(.blue.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .cardBackground()
            .tapHint()
        }
    }
}

#Preview {
    WelcomePage()
}
