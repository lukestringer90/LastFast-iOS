//
//  FastingView.swift
//  LastFast
//
//  Main fasting screen - displays active fast timer or start fast interface
//

import SwiftUI
import SwiftData
import WidgetKit

// MARK: - Feature Flags

let useGraphHistoryView = true

// MARK: - Fasting View

struct FastingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]

    @State private var timer: Timer?
    @State private var liveActivityTimer: Timer?
    @State private var currentTime = Date()
    @State private var showingHistory = false
    @State private var showingGoalPicker = false
    @State private var showingStopConfirmation = false
    @State private var goalNotificationSent = false
    @State private var confettiInstances: [UUID] = []

    @AppStorage("fastingGoalMinutes") private var savedGoalMinutes: Int = 720

    // MARK: - Computed Properties

    private var activeFast: FastingSession? {
        sessions.first { $0.isActive }
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

    private var lastCompletedFastDuration: TimeInterval? {
        sessions.first { !$0.isActive }?.duration
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                VStack(spacing: 0) {
                    if let fast = activeFast {
                        let endTime = fast.goalMinutes.map { fast.startTime.addingTimeInterval(TimeInterval($0 * 60)) }
                        ActiveFastingView(
                            goalMet: goalMet,
                            hours: hours,
                            minutes: minutes,
                            elapsedHours: elapsedHours,
                            elapsedMins: elapsedMins,
                            progress: progress,
                            startTime: fast.startTime,
                            endTime: endTime,
                            goalMinutes: fast.goalMinutes,
                            lastFastDuration: lastCompletedFastDuration,
                            onStopFast: { showingStopConfirmation = true },
                            onShowHistory: { showingHistory = true },
                            onCelebrate: goalMet ? { confettiInstances.append(UUID()) } : nil
                        )
                    } else {
                        NotFastingView(
                            savedGoalMinutes: savedGoalMinutes,
                            lastFastDuration: lastCompletedFastDuration,
                            onStartFast: startFasting,
                            onShowGoalPicker: { showingGoalPicker = true },
                            onShowHistory: { showingHistory = true }
                        )
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.4), value: activeFast != nil)
                .animation(.easeInOut(duration: 0.4), value: goalMet)

                ForEach(confettiInstances, id: \.self) { confettiId in
                    ConfettiView(id: confettiId) { completedId in
                        confettiInstances.removeAll { $0 == completedId }
                    }
                }
            }
            .onAppear(perform: handleAppear)
            .onDisappear { stopTimer() }
            .onChange(of: goalMet) { _, newValue in
                if newValue {
                    checkForGoalCelebration()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                WidgetCenter.shared.reloadAllTimelines()
                checkForGoalCelebration()
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

    @Environment(\.colorScheme) private var colorScheme

    private var backgroundGradient: some View {
        let color: Color = {
            let isDark = colorScheme == .dark

            if activeFast == nil {
                // Idle: Plain background
                return isDark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color(red: 0.98, green: 0.97, blue: 0.95)
            } else if goalMet {
                // Goal Met: Subtle green tint
                return isDark ? Color(red: 0.08, green: 0.14, blue: 0.08) : Color(red: 0.9, green: 0.96, blue: 0.9)
            } else {
                // Active Fasting: Subtle warm tint
                return isDark ? Color(red: 0.14, green: 0.11, blue: 0.1) : Color(red: 0.98, green: 0.95, blue: 0.92)
            }
        }()

        return color.ignoresSafeArea()
    }

    // MARK: - Actions

    private func handleAppear() {
        #if DEBUG
        DataSnapshotManager.shared.handleLaunchArguments(context: modelContext)
        #endif

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
        checkForGoalCelebration()
    }

    private func checkForGoalCelebration() {
        guard let fast = activeFast,
              fast.goalMet,
              !fast.goalCelebrationShown else { return }

        fast.goalCelebrationShown = true
        try? modelContext.save()
        confettiInstances.append(UUID())
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

#Preview("Not Fasting") {
    NotFastingView(
        savedGoalMinutes: 720,
        lastFastDuration: 16.5 * 3600,
        onStartFast: {},
        onShowGoalPicker: {},
        onShowHistory: {}
    )
}

#Preview("In Progress") {
    ActiveFastingView(
        goalMet: false,
        hours: 8,
        minutes: 30,
        elapsedHours: 3,
        elapsedMins: 30,
        progress: 0.45,
        startTime: Date().addingTimeInterval(-3.5 * 3600),
        endTime: Date().addingTimeInterval(8.5 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
}

#Preview("Goal Met") {
    ActiveFastingView(
        goalMet: true,
        hours: 0,
        minutes: 0,
        elapsedHours: 16,
        elapsedMins: 5,
        progress: 1.0,
        startTime: Date().addingTimeInterval(-16.1 * 3600),
        endTime: nil,
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
}
