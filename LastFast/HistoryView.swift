//
//  HistoryView.swift
//  LastFast
//
//  View for displaying fasting history with list and graph options
//

import SwiftUI
import SwiftData

// MARK: - History View Configuration

/// Set to `true` to show the graph view, `false` to show the simple list view
let useGraphHistoryView = false

// MARK: - History View

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    @State private var selectedSession: FastingSession?
    
    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }
    
    private var chartSessions: [FastingSession] {
        Array(completedSessions.reversed().suffix(14))
    }
    
    private var maxDuration: TimeInterval {
        chartSessions.max(by: { $0.duration < $1.duration })?.duration ?? 3600
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if completedSessions.isEmpty {
                    emptyStateView
                } else if useGraphHistoryView {
                    graphView
                } else {
                    listView
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
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
    
    // MARK: - Graph View
    
    private var graphView: some View {
        ScrollView {
            VStack(spacing: 24) {
                barChart
                    .padding(.top, 16)
                
                if let session = selectedSession {
                    selectedSessionCard(session: session)
                }
                
                statsCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Bar Chart
    
    private var barChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fasting History")
                .font(.headline)
            
            GeometryReader { geometry in
                let barWidth = max(20, (geometry.size.width - CGFloat(chartSessions.count - 1) * 4) / CGFloat(max(chartSessions.count, 1)))
                let chartHeight: CGFloat = 200
                
                VStack(spacing: 0) {
                    // Bars
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(chartSessions) { session in
                            let barHeight = maxDuration > 0 ? CGFloat(session.duration / maxDuration) * chartHeight : 0
                            let isSelected = selectedSession?.id == session.id
                            
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor(for: session, isSelected: isSelected))
                                    .frame(width: barWidth, height: max(barHeight, 4))
                            }
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedSession?.id == session.id {
                                        selectedSession = nil
                                    } else {
                                        selectedSession = session
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: chartHeight, alignment: .bottom)
                    
                    // X-axis labels
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(chartSessions) { session in
                            Text(formatChartDate(session.startTime))
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                                .frame(width: barWidth)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(height: 240)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func barColor(for session: FastingSession, isSelected: Bool) -> Color {
        if isSelected {
            return session.goalMet ? .green : .orange
        } else {
            return session.goalMet ? .green.opacity(0.6) : .orange.opacity(0.6)
        }
    }
    
    // MARK: - Selected Session Card
    
    private func selectedSessionCard(session: FastingSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                
                Spacer()
                
                if session.goalMinutes != nil {
                    Image(systemName: session.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(session.goalMet ? .green : .red)
                }
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    let (hours, minutes) = hoursAndMinutes(from: session.duration)
                    Text(formatDuration(hours: hours, minutes: minutes))
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Text(format24HourTime(session.startTime))
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                        Text(session.endTime.map { format24HourTime($0) } ?? "—")
                    }
                    .font(.subheadline)
                }
            }
            
            if let goal = session.goalMinutes {
                Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Stats Card
    
    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            HStack(spacing: 12) {
                StatBox(
                    title: "Total Fasts",
                    value: "\(completedSessions.count)"
                )
                
                StatBox(
                    title: "Goals Met",
                    value: "\(completedSessions.filter { $0.goalMet }.count)"
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
    
    private var averageDuration: TimeInterval? {
        guard !completedSessions.isEmpty else { return nil }
        let total = completedSessions.reduce(0) { $0 + $1.duration }
        return total / Double(completedSessions.count)
    }
    
    // MARK: - Helpers
    
    private func formatChartDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
