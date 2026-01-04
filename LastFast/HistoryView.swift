//
//  HistoryView.swift
//  LastFast
//
//  View for displaying fasting history with list and graph options
//

import SwiftUI
import SwiftData

// MARK: - History View

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    @State private var selectedSession: FastingSession?
    @State private var showingListView = false
    
    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }
    
    private var chartSessions: [FastingSession] {
        Array(completedSessions.reversed().suffix(5))
    }
    
    private var maxDuration: TimeInterval {
        let maxFasted = chartSessions.max(by: { $0.duration < $1.duration })?.duration ?? 3600
        let maxGoal = chartSessions.compactMap { $0.goalMinutes }.max().map { TimeInterval($0 * 60) } ?? 0
        return max(maxFasted, maxGoal)
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
            .sheet(isPresented: $showingListView) {
                HistoryListView()
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
    
    private func deleteSession(_ session: FastingSession) {
        withAnimation {
            selectedSession = nil
            modelContext.delete(session)
            try? modelContext.save()
        }
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
                
                // View All Fasts button
                Button(action: { showingListView = true }) {
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
                
                statsCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Bar Chart
    
    private var barChart: some View {
        GeometryReader { geometry in
            let barWidth = max(40, (geometry.size.width - CGFloat(chartSessions.count - 1) * 8 - 32) / CGFloat(max(chartSessions.count, 1)))
            let durationLabelHeight: CGFloat = 20
            let dateLabelHeight: CGFloat = 20
            let barAreaHeight: CGFloat = 160
            
            VStack(spacing: 0) {
                // Duration labels row
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(chartSessions) { session in
                        Text(formatShortDuration(session.duration))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: barWidth, height: durationLabelHeight)
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
                
                // Bars and goal line area
                ZStack(alignment: .bottom) {
                    // Bars
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(chartSessions) { session in
                            let barHeight = maxDuration > 0 ? max(4, CGFloat(session.duration / maxDuration) * barAreaHeight) : 4
                            let isSelected = selectedSession?.id == session.id
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(barColor(for: session, isSelected: isSelected))
                                .frame(width: barWidth, height: barHeight)
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
                    
                    // Goal line overlay
                    Path { path in
                        let points = chartSessions.enumerated().compactMap { index, session -> CGPoint? in
                            guard let goalMinutes = session.goalMinutes, maxDuration > 0 else { return nil }
                            let x = CGFloat(index) * (barWidth + 8) + barWidth / 2
                            let goalHeight = CGFloat(TimeInterval(goalMinutes * 60) / maxDuration) * barAreaHeight
                            let y = barAreaHeight - goalHeight
                            return CGPoint(x: x, y: y)
                        }
                        
                        if let first = points.first {
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // Goal line dots
                    ForEach(Array(chartSessions.enumerated()), id: \.element.id) { index, session in
                        if let goalMinutes = session.goalMinutes, maxDuration > 0 {
                            let x = CGFloat(index) * (barWidth + 8) + barWidth / 2
                            let goalHeight = CGFloat(TimeInterval(goalMinutes * 60) / maxDuration) * barAreaHeight
                            let y = barAreaHeight - goalHeight
                            
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: barAreaHeight)
                
                // X-axis labels (dates)
                HStack(alignment: .top, spacing: 8) {
                    ForEach(chartSessions) { session in
                        Text(formatChartDate(session.startTime))
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth, height: dateLabelHeight)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 240)
        .padding(.vertical, 16)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteSession(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                deleteSession(session)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
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
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
    
    private func formatShortDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - History List View

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(completedSessions) { session in
                    FastingHistoryRow(session: session)
                }
                .onDelete(perform: deleteSessions)
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
        }
    }
    
    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedSessions[index])
        }
        try? modelContext.save()
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
