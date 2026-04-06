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
        SessionCard(session: session)
            .contentShape(Rectangle())
            .onTapGesture {
                showingEditSheet = true
            }
            .sheet(isPresented: $showingEditSheet) {
                EditFastView(session: session)
            }
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
