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

    @State private var showingEditSheet = false

    
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
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
        .sheet(isPresented: $showingEditSheet) {
            EditFastView(session: session)
        }
    }
    
    // MARK: - Subviews
    
    private var dateAndStatusRow: some View {
        HStack(spacing: 8) {
            Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)

            if session.goalMinutes != nil {
                GoalStatusIcon(goalMet: session.goalMet)
            }
        }
    }

    private var timeRangeRow: some View {
        TimeRangeLabel(startTime: session.startTime, endTime: session.endTime)
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
        Text(formatDuration(from: session.duration))
            .font(.system(.title3, design: .rounded))
            .fontWeight(.semibold)
            .foregroundStyle(GoalStatusColors.durationColor(goalMet: session.goalMet))
    }
}

// MARK: - Preview

#Preview("Goal Met") {
    List {
        FastingHistoryRow(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-57600), // 16h ago
                goalMinutes: defaultFastingGoalMinutes
            )
            session.endTime = Date()
            return session
        }())
    }
}

#Preview("Goal Not Met") {
    List {
        FastingHistoryRow(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-7200), // 2h ago
                goalMinutes: defaultFastingGoalMinutes
            )
            session.endTime = Date()
            return session
        }())
    }
}

#Preview("No Goal") {
    List {
        FastingHistoryRow(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-28800) // 8h ago
            )
            session.endTime = Date()
            return session
        }())
    }
}
