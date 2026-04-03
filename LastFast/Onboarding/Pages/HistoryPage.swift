// HistoryPage.swift
// LastFast

import SwiftUI

struct HistoryPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "clock.arrow.circlepath",
            iconColor: .purple,
            title: "Review Your History",
            description: "Every completed fast is saved. Tap the history button to see your streak, graph, and individual session details."
        ) {
            VStack(spacing: 0) {
                sessionRow(duration: "16h 10m", durationColor: .green, date: "Yesterday")
                Divider()
                    .padding(.leading, 44)
                sessionRow(duration: "14h 30m", durationColor: .orange, date: "2 days ago")
            }
            .cardBackground(padding: 0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .tapHint()
        }
    }

    private func sessionRow(duration: String, durationColor: Color, date: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(duration)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(durationColor)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    HistoryPage()
}
