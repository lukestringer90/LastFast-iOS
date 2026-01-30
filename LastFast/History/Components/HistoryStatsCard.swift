//
//  HistoryStatsCard.swift
//  LastFast
//
//  Card view for displaying fasting statistics
//

import SwiftUI

struct HistoryStatsCard: View {
    let sessions: [FastingSession]

    private var averageDuration: TimeInterval? {
        guard !sessions.isEmpty else { return nil }
        let total = sessions.reduce(0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)

            HStack(spacing: 12) {
                StatBox(
                    title: "Total Fasts",
                    value: "\(sessions.count)"
                )

                StatBox(
                    title: "Goals Met",
                    value: "\(sessions.filter { $0.goalMet }.count)"
                )

                if let avgDuration = averageDuration {
                    let (hours, minutes) = hoursAndMinutes(from: avgDuration)
                    StatBox(
                        title: "Avg Duration",
                        value: formatDuration(hours: hours, minutes: minutes)
                    )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    HistoryStatsCard(sessions: [])
        .padding()
}
