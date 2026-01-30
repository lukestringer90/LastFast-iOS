//
//  HistoryBarChart.swift
//  LastFast
//
//  Bar chart view for displaying fasting session history
//

import SwiftUI

struct HistoryBarChart: View {
    let sessions: [FastingSession]
    @Binding var selectedSession: FastingSession?

    private var maxDuration: TimeInterval {
        let maxFasted = sessions.max(by: { $0.duration < $1.duration })?.duration ?? 3600
        let maxGoal = sessions.compactMap { $0.goalMinutes }.max().map { TimeInterval($0 * 60) } ?? 0
        return max(maxFasted, maxGoal)
    }

    var body: some View {
        GeometryReader { geometry in
            let barWidth = max(40, (geometry.size.width - CGFloat(sessions.count - 1) * 8 - 32) / CGFloat(max(sessions.count, 1)))
            let durationLabelHeight: CGFloat = 20
            let dateLabelHeight: CGFloat = 20
            let barAreaHeight: CGFloat = 160

            VStack(spacing: 0) {
                durationLabelsRow(barWidth: barWidth, height: durationLabelHeight)
                barsAndGoalLine(barWidth: barWidth, barAreaHeight: barAreaHeight)
                    .frame(height: barAreaHeight)
                dateLabelsRow(barWidth: barWidth, height: dateLabelHeight)
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

    // MARK: - Subviews

    private func durationLabelsRow(barWidth: CGFloat, height: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(sessions) { session in
                Text(formatShortDuration(session.duration))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: barWidth, height: height)
                    .onTapGesture {
                        toggleSelection(session)
                    }
            }
        }
    }

    private func barsAndGoalLine(barWidth: CGFloat, barAreaHeight: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            barsRow(barWidth: barWidth, barAreaHeight: barAreaHeight)
            goalLine(barWidth: barWidth, barAreaHeight: barAreaHeight)
            goalDots(barWidth: barWidth, barAreaHeight: barAreaHeight)
        }
    }

    private func barsRow(barWidth: CGFloat, barAreaHeight: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(sessions) { session in
                let barHeight = maxDuration > 0 ? max(4, CGFloat(session.duration / maxDuration) * barAreaHeight) : 4
                let isSelected = selectedSession?.id == session.id

                RoundedRectangle(cornerRadius: 6)
                    .fill(barColor(for: session, isSelected: isSelected))
                    .frame(width: barWidth, height: barHeight)
                    .onTapGesture {
                        toggleSelection(session)
                    }
            }
        }
    }

    private func goalLine(barWidth: CGFloat, barAreaHeight: CGFloat) -> some View {
        Path { path in
            let points = sessions.enumerated().compactMap { index, session -> CGPoint? in
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
    }

    private func goalDots(barWidth: CGFloat, barAreaHeight: CGFloat) -> some View {
        ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
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

    private func dateLabelsRow(barWidth: CGFloat, height: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(sessions) { session in
                Text(formatChartDate(session.startTime))
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .frame(width: barWidth, height: height)
            }
        }
    }

    // MARK: - Helpers

    private func toggleSelection(_ session: FastingSession) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedSession?.id == session.id {
                selectedSession = nil
            } else {
                selectedSession = session
            }
        }
    }

    private func barColor(for session: FastingSession, isSelected: Bool) -> Color {
        if isSelected {
            return session.goalMet ? .green : .orange
        } else {
            return session.goalMet ? .green.opacity(0.6) : .orange.opacity(0.6)
        }
    }

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

// MARK: - Preview

#Preview {
    HistoryBarChart(
        sessions: [],
        selectedSession: .constant(nil)
    )
    .padding()
}
