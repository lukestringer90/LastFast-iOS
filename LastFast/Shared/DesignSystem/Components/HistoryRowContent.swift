//
//  HistoryRowContent.swift
//  LastFast
//
//  Reusable layout for a fasting history row, used in both the history list and onboarding
//

import SwiftUI

struct HistoryRowContent: View {
    let duration: String
    let durationColor: Color
    let date: String
    let startTime: String
    let endTime: String
    let goalText: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(duration)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(durationColor)

                Text(date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Text(startTime)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(endTime)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let goalText {
                    Text("Goal: \(goalText)")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        HistoryRowContent(
            duration: "16h 10m",
            durationColor: .green,
            date: "5 Apr 2026",
            startTime: "18:42",
            endTime: "19:58",
            goalText: "16h"
        )
        HistoryRowContent(
            duration: "3m",
            durationColor: .orange,
            date: "5 Apr 2026",
            startTime: "17:15",
            endTime: "17:19",
            goalText: "1h 1m"
        )
    }
}
