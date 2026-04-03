// WelcomePage.swift
// LastFast

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "bolt.heart.fill",
            iconColor: .orange,
            title: "Welcome to LastFast",
            description: "Track your intermittent fasts and hit your goals. Start by setting how long you want to fast."
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

                Text("Ends: 08:00")
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
