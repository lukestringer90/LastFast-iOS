//
//  ContentView.swift
//  LastFast
//
//  Main iOS app view
//

import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Feature Flags

let useGraphHistoryView = true

// MARK: - Content View

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]

    @State private var timer: Timer?
    @State private var liveActivityTimer: Timer?
    @State private var currentTime = Date()
    @State private var showingHistory = false
    @State private var showingGoalPicker = false
    @State private var showingStopConfirmation = false
    @State private var goalNotificationSent = false

    @AppStorage("fastingGoalMinutes") private var savedGoalMinutes: Int = 720

    // MARK: - Computed Properties

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

    private var remainingMinutes: Int {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }

    private var hours: Int { remainingMinutes / 60 }
    private var minutes: Int { remainingMinutes % 60 }
    private var elapsedHours: Int { Int(currentDuration) / 3600 }
    private var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }

    private var goalMet: Bool {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }

    private var progress: Double {
        guard let fast = activeFast, let goal = fast.goalMinutes, goal > 0 else { return 0 }
        return min(1.0, (currentDuration / 60) / Double(goal))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                VStack(spacing: 0) {
                    if activeFast != nil {
                        ActiveFastingView(
                            goalMet: goalMet,
                            hours: hours,
                            minutes: minutes,
                            elapsedHours: elapsedHours,
                            elapsedMins: elapsedMins,
                            progress: progress,
                            activeFast: activeFast,
                            lastFast: lastFast,
                            onStopFast: { showingStopConfirmation = true },
                            onShowHistory: { showingHistory = true }
                        )
                    } else {
                        NotFastingView(
                            savedGoalMinutes: savedGoalMinutes,
                            currentTime: currentTime,
                            lastFast: lastFast,
                            onStartFast: startFasting,
                            onShowGoalPicker: { showingGoalPicker = true },
                            onShowHistory: { showingHistory = true }
                        )
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.4), value: activeFast != nil)
            }
            .onAppear(perform: handleAppear)
            .onDisappear { stopTimer() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showingGoalPicker) {
                GoalPickerView(goalMinutes: $savedGoalMinutes)
            }
            .alert("Stop Fast?", isPresented: $showingStopConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Stop Fast", role: .destructive) {
                    stopFasting()
                }
            } message: {
                Text("Are you sure you want to stop your fast? You've been fasting for \(formatDuration(hours: elapsedHours, minutes: elapsedMins)).")
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: activeFast != nil ? [Color.orange.opacity(0.1), Color.orange.opacity(0.05)] : [Color(.systemBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Actions

    private func handleAppear() {
        startTimer()
        if liveActivityEnabled {
            LiveActivityManager.resumeIfNeeded(
                startTime: activeFast?.startTime,
                goalMinutes: activeFast?.goalMinutes ?? savedGoalMinutes
            )
        }
        NotificationManager.requestPermission()
        if activeFast == nil {
            goalNotificationSent = false
        }
    }

    private func startFasting() {
        let newSession = FastingSession(goalMinutes: savedGoalMinutes)
        modelContext.insert(newSession)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()

        let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
        defaults?.set(newSession.startTime.timeIntervalSince1970, forKey: "fastingStartTime")
        defaults?.set(savedGoalMinutes, forKey: "fastingGoalMinutes")
        defaults?.set(true, forKey: "isFasting")

        goalNotificationSent = false
        NotificationManager.scheduleOneHourBeforeNotification(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)
        NotificationManager.scheduleGoalNotification(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)

        LiveActivityManager.start(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)
    }

    private func stopFasting() {
        if let fast = activeFast {
            fast.stop()
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()

            let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
            defaults?.set(false, forKey: "isFasting")
            defaults?.removeObject(forKey: "fastingStartTime")

            NotificationManager.cancelGoalNotification()
            goalNotificationSent = false

            LiveActivityManager.end()
        }
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.currentTime = Date()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)

        if liveActivityEnabled {
            liveActivityTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    if let fast = self.activeFast {
                        LiveActivityManager.update(startTime: fast.startTime, goalMinutes: fast.goalMinutes)
                    }
                }
            }
            RunLoop.main.add(liveActivityTimer!, forMode: .common)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        liveActivityTimer?.invalidate()
        liveActivityTimer = nil
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
