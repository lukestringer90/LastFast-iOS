// WelcomePage.swift
// LastFast

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "bolt.heart.fill",
            iconColor: .orange,
            title: "Welcome to LastFast",
            description: "Track your intermittent fasts, hit your goals, and build a healthy habit — all from one simple screen."
        ) {
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.orange)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "timer")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    )

                Text("LastFast")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Intermittent Fasting Tracker")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .cardBackground()
        }
    }
}

#Preview {
    WelcomePage()
}
