// NotificationsPage.swift
// LastFast

import SwiftUI

struct NotificationsPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "bell.badge.fill",
            iconColor: .orange,
            title: "Stay on Track",
            description: "LastFast can notify you one hour before your goal and when you've achieved it. You can change this in Settings any time."
        ) {
            VStack(spacing: 10) {
                notificationBanner(
                    title: "⏰ One Hour to Go!",
                    body: "You're almost there! Your goal will be complete at 08:00"
                )
                notificationBanner(
                    title: "🎉 Goal Achieved - 16h",
                    body: "Amazing work! You fasted from 16:00 → 08:00"
                )
            }
        }
    }

    private func notificationBanner(title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image("AppIconDisplay")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .cardBackground()
    }
}

#Preview {
    NotificationsPage()
}
