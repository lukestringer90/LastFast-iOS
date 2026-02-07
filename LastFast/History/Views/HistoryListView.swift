//
//  HistoryListView.swift
//  LastFast
//
//  View for displaying all fasting sessions in a list
//

import SwiftUI
import SwiftData
import FirebaseAnalytics // Added for AnalyticsManager
import AppTrackingTransparency // For AnalyticsManager.swift

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]

    @State private var sessionToEdit: FastingSession?

    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(completedSessions) { session in
                    SessionCard(session: session)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteSession(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                sessionToEdit = session
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("All Fasts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $sessionToEdit) { session in
                EditFastView(session: session)
            }
        }
        .onAppear {
            AnalyticsManager.logEvent("view_full_fast_list")
        }
    }

    private func deleteSession(_ session: FastingSession) {
        modelContext.delete(session)
        try? modelContext.save()
    }
}

// MARK: - Preview

#Preview {
    HistoryListView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
