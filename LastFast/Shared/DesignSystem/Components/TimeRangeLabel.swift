//
//  TimeRangeLabel.swift
//  LastFast
//
//  Reusable component for displaying time ranges
//

import SwiftUI

// MARK: - Time Range Label

struct TimeRangeLabel: View {
    let startTime: Date
    let endTime: Date?
    var font: Font = .subheadline

    var body: some View {
        HStack(spacing: 4) {
            Text(format24HourTime(startTime))
            Image(systemName: "arrow.right")
                .font(.caption2)
            Text(endTime.map { format24HourTime($0) } ?? "—")
        }
        .font(font)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        TimeRangeLabel(
            startTime: Date().addingTimeInterval(-8 * 3600),
            endTime: Date()
        )

        TimeRangeLabel(
            startTime: Date(),
            endTime: nil
        )
    }
}
