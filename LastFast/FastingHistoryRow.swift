//
//  FastingHistoryRow.swift
//  LastFast
//
//  Row view for displaying a single fasting session in the history list
//

import SwiftUI

// MARK: - Fasting History Row

struct FastingHistoryRow: View {
    let session: FastingSession
    
    private var hours: Int {
        Int(session.duration) / 3600
    }
    
    private var minutes: Int {
        (Int(session.duration) % 3600) / 60
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                dateAndStatusRow
                timeRangeRow
                goalRow
            }
            
            Spacer()
            
            durationLabel
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Subviews
    
    private var dateAndStatusRow: some View {
        HStack(spacing: 8) {
            Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            
            if session.goalMinutes != nil {
                Image(systemName: session.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(session.goalMet ? .green : .red)
                    .font(.subheadline)
            }
        }
    }
    
    private var timeRangeRow: some View {
        HStack(spacing: 4) {
            Text(format24HourTime(session.startTime))
            Image(systemName: "arrow.right")
                .font(.caption2)
            Text(session.endTime.map { format24HourTime($0) } ?? "—")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var goalRow: some View {
        if let goal = session.goalMinutes {
            Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var durationLabel: some View {
        Text(formatDuration(hours: hours, minutes: minutes))
            .font(.system(.title3, design: .rounded))
            .fontWeight(.semibold)
            .foregroundStyle(session.goalMet ? .green : .orange)
    }
}

// MARK: - Preview

#Preview {
    List {
        FastingHistoryRow(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-57600),
                goalMinutes: 720
            )
            session.endTime = Date()
            return session
        }())
    }
}
