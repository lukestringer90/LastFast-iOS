// WatchContentView.swift
// LastFastWatch
// Simple start/stop interface for watchOS

import SwiftUI
import SwiftData
import WidgetKit

struct WatchContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    @State private var timer: Timer?
    @State private var currentTime = Date()
    @State private var showingStopConfirmation = false
    @AppStorage(fastingGoalStorageKey) private var savedGoalMinutes: Int = defaultFastingGoalMinutes
    
    private var activeFast: FastingSession? {
        sessions.first { $0.isActive }
    }
    
    private var lastFast: FastingSession? {
        sessions.first { !$0.isActive }
    }
    
    private var currentDuration: TimeInterval {
        guard let fast = activeFast else { return 0 }
        return currentTime.timeIntervalSince(fast.startTime)
    }
    
    private var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    private var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    private var remainingMinutes: Int {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    private var hours: Int {
        remainingMinutes / 60
    }
    
    private var minutes: Int {
        remainingMinutes % 60
    }
    
    private var goalMet: Bool {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    private var progress: Double {
        guard let fast = activeFast, let goal = fast.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if activeFast != nil {
                    // Fasting view
                    fastingView
                } else {
                    // Not fasting view
                    notFastingView
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .confirmationDialog("Stop Fast?", isPresented: $showingStopConfirmation, titleVisibility: .visible) {
            Button("Stop Fast", role: .destructive) {
                stopFasting()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You've fasted for \(formatDuration(hours: elapsedHours, minutes: elapsedMins)).")
        }
    }
    
    // MARK: - Fasting View
    
    private var fastingView: some View {
        VStack(spacing: 6) {
            // Label
            Text(goalMet ? "You've fasted for" : "Keep fasting")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            // Countdown or elapsed time
            if goalMet {
                timeDisplay(h: elapsedHours, m: elapsedMins, color: .green)
            } else {
                timeDisplay(h: hours, m: minutes, color: .orange)
            }
            
            // Progress bar (only show when goal not met)
            if !goalMet {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.darkGray))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.orange)
                            .frame(width: geometry.size.width * progress, height: 6)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
            }
            
            // Goal info
            VStack(spacing: 2) {
                if goalMet {
                    Text("🎉 Goal reached!")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    Text("\(formatDuration(hours: elapsedHours, minutes: elapsedMins)) fasted")
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
                
                if let goal = activeFast?.goalMinutes {
                    Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Stop button
            Button(action: { showingStopConfirmation = true }) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop")
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top, 4)
        }
    }
    
    // MARK: - Not Fasting View
    
    private var notFastingView: some View {
        VStack(spacing: 8) {
            // Goal display
            VStack(spacing: 2) {
                Text("Goal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                Text(formatDuration(hours: savedGoalMinutes / 60, minutes: savedGoalMinutes % 60))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            // Start button
            Button(action: startFasting) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Fast")
                }
                .font(.caption)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            
            // Last fast info
            if let last = lastFast {
                VStack(spacing: 2) {
                    Text("Last Fast")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    let h = Int(last.duration) / 3600
                    let m = (Int(last.duration) % 3600) / 60
                    
                    HStack(spacing: 4) {
                        Text(formatDuration(hours: h, minutes: m))
                            .font(.headline)
                            .foregroundStyle(last.goalMet ? .green : .orange)
                        
                        if last.goalMinutes != nil {
                            Image(systemName: last.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(last.goalMet ? .green : .red)
                                .font(.caption2)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Time Display
    
    private func timeDisplay(h: Int, m: Int, color: Color) -> some View {
        Group {
            if h > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(h)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text("h")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(color.opacity(0.7))
                    Text("\(m)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text("m")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(color.opacity(0.7))
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(m)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text("m")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(color.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func startFasting() {
        let newSession = FastingSession(goalMinutes: savedGoalMinutes)
        modelContext.insert(newSession)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func stopFasting() {
        if let fast = activeFast {
            fast.stop()
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            DispatchQueue.main.async {
                self.currentTime = Date()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Formatting
    
    private func formatDuration(hours: Int, minutes: Int) -> String {
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    WatchContentView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
