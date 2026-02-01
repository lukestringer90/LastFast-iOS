//
//  HistoryView.swift
//  LastFast
//
//  View for displaying fasting history with list and graph options
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]

    @State private var selectedSession: FastingSession?
    @State private var showingListView = false
    @State private var sessionToEdit: FastingSession?

    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("History")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingListView) {
                    HistoryListView()
                }
                .sheet(item: $sessionToEdit) { session in
                    EditFastView(session: session)
                }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if completedSessions.isEmpty {
            emptyStateView
        } else if useGraphHistoryView {
            HistoryGraphView(
                sessions: completedSessions,
                selectedSession: $selectedSession,
                sessionToEdit: $sessionToEdit,
                onShowListView: { showingListView = true },
                onDeleteSession: deleteSession
            )
        } else {
            listView
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Fasting History",
            systemImage: "clock.badge.questionmark",
            description: Text("Complete your first fast to see it here")
        )
    }

    // MARK: - List View

    private var listView: some View {
        List {
            ForEach(completedSessions) { session in
                FastingHistoryRow(session: session)
            }
            .onDelete(perform: deleteSessions)
        }
        .listStyle(.insetGrouped)
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedSessions[index])
        }
        try? modelContext.save()
    }

    private func deleteSession(_ session: FastingSession) {
        withAnimation {
            selectedSession = nil
            modelContext.delete(session)
            try? modelContext.save()
        }
    }
}

// MARK: - Preview

@MainActor
private func previewContainer() -> ModelContainer {
    let container = try! ModelContainer(for: FastingSession.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let context = container.mainContext

    let session1 = FastingSession(startTime: Date().addingTimeInterval(-5 * 86400 - 57600), goalMinutes: defaultFastingGoalMinutes)
    session1.endTime = Date().addingTimeInterval(-5 * 86400)
    context.insert(session1)

    let session2 = FastingSession(startTime: Date().addingTimeInterval(-4 * 86400 - 50400), goalMinutes: 960)
    session2.endTime = Date().addingTimeInterval(-4 * 86400)
    context.insert(session2)

    let session3 = FastingSession(startTime: Date().addingTimeInterval(-3 * 86400 - 28800))
    session3.endTime = Date().addingTimeInterval(-3 * 86400)
    context.insert(session3)

    let session4 = FastingSession(startTime: Date().addingTimeInterval(-2 * 86400 - 36000), goalMinutes: defaultFastingGoalMinutes)
    session4.endTime = Date().addingTimeInterval(-2 * 86400)
    context.insert(session4)

    let session5 = FastingSession(startTime: Date().addingTimeInterval(-1 * 86400 - 64800), goalMinutes: 960)
    session5.endTime = Date().addingTimeInterval(-1 * 86400)
    context.insert(session5)

    return container
}

#Preview("With Data") {
    HistoryView()
        .modelContainer(previewContainer())
}

#Preview("Empty State") {
    HistoryView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
