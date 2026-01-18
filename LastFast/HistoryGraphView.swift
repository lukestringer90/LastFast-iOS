//
//  HistoryGraphView.swift
//  LastFast
//
//  Graph view for displaying fasting history with bar chart and stats
//

import SwiftUI

struct HistoryGraphView: View {
    let sessions: [FastingSession]
    @Binding var selectedSession: FastingSession?
    @Binding var sessionToEdit: FastingSession?
    var onShowListView: () -> Void
    var onDeleteSession: (FastingSession) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HistoryBarChart(sessions: chartSessions, selectedSession: $selectedSession)
                    .padding(.top, 16)

                if let session = selectedSession {
                    SessionCard(
                        session: session,
                        onEdit: { sessionToEdit = session },
                        onDelete: { onDeleteSession(session) },
                        showBackground: true
                    )
                    .padding(.horizontal, 4)
                }

                Button(action: onShowListView) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("View All Fasts")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }

                HistoryStatsCard(sessions: sessions)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private var chartSessions: [FastingSession] {
        Array(sessions.reversed().suffix(5))
    }
}

// MARK: - Preview

#Preview {
    HistoryGraphView(
        sessions: [],
        selectedSession: .constant(nil),
        sessionToEdit: .constant(nil),
        onShowListView: {},
        onDeleteSession: { _ in }
    )
}
