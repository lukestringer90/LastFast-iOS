//
//  ContentView.swift
//  LastFast
//
//  Main iOS app view
//

import SwiftUI
import SwiftData
import WidgetKit

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
                        activeFastingView
                    } else {
                        notFastingView
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
    
    // MARK: - Main Layout Views
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: activeFast != nil ? [Color.orange.opacity(0.1), Color.orange.opacity(0.05)] : [Color(.systemBackground), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var activeFastingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            TimerDisplayView(
                goalMet: goalMet,
                hours: hours,
                minutes: minutes,
                elapsedHours: elapsedHours,
                elapsedMins: elapsedMins,
                progress: progress
            )
            .transition(.opacity.combined(with: .scale(scale: 0.8)))
            
            goalAndStartTimeView
                .padding(.top, 24)
                .transition(.opacity.combined(with: .move(edge: .top)))
            
            Spacer()
            
            actionButton
            
            historyButton
                .padding(.top, 16)
                .padding(.bottom, 40)
        }
    }
    
    private var historyButton: some View {
        Button(action: { showingHistory = true }) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.subheadline)
                Text("History")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private var notFastingView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                goalSetterView
                    .transition(.opacity)
                
                actionButton
            }
            
            Spacer()
            
            lastFastButton
                .padding(.top, 16)
            
            historyButton
                .padding(.top, 12)
                .padding(.bottom, 40)
        }
    }
    
    // MARK: - Subviews
    
    private var goalAndStartTimeView: some View {
        VStack(spacing: 4) {
            if goalMet {
                Text("🎉 Goal reached!")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Text("\(formatDuration(hours: elapsedHours, minutes: elapsedMins)) fasted")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            if let fast = activeFast, let goal = fast.goalMinutes {
                let completionTime = fast.startTime.addingTimeInterval(TimeInterval(goal * 60))
                Text("\(format24HourTime(fast.startTime)) → \(format24HourTime(completionTime))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private var goalSetterView: some View {
        Button(action: { showingGoalPicker = true }) {
            VStack(spacing: 4) {
                Text("Goal: \(formatDuration(hours: savedGoalMinutes / 60, minutes: savedGoalMinutes % 60))")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                let estimatedFinish = currentTime.addingTimeInterval(TimeInterval(savedGoalMinutes * 60))
                Text("Finish at \(format24HourTime(estimatedFinish))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Tap to change")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
    
    private var actionButton: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            toggleFasting()
        }) {
            HStack(spacing: 12) {
                Image(systemName: activeFast != nil ? "stop.fill" : "play.fill")
                    .font(.title2)
                Text(activeFast != nil ? "Stop Fast" : "Start Fast")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(activeFast != nil ? Color.red : Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 20)
    }
    
    private var lastFastButton: some View {
        Button(action: { showingHistory = true }) {
            LastFastButtonContent(lastFast: lastFast)
        }
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
    
    private func toggleFasting() {
        if activeFast != nil {
            showingStopConfirmation = true
        } else {
            startFasting()
        }
    }
    
    private func startFasting() {
        let newSession = FastingSession(goalMinutes: savedGoalMinutes)
        modelContext.insert(newSession)
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
        
        // Save to UserDefaults for background task access
        let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
        defaults?.set(newSession.startTime.timeIntervalSince1970, forKey: "fastingStartTime")
        defaults?.set(savedGoalMinutes, forKey: "fastingGoalMinutes")
        defaults?.set(true, forKey: "isFasting")
        
        // Reset notification flag and schedule goal notification
        goalNotificationSent = false
        NotificationManager.scheduleGoalNotification(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)
        
        // Start Live Activity
        LiveActivityManager.start(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)
    }
    
    private func stopFasting() {
        if let fast = activeFast {
            fast.stop()
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            
            // Clear UserDefaults
            let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
            defaults?.set(false, forKey: "isFasting")
            defaults?.removeObject(forKey: "fastingStartTime")
            
            // Cancel pending notifications
            NotificationManager.cancelGoalNotification()
            goalNotificationSent = false
            
            // End Live Activity
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
