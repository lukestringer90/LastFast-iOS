// ContentView.swift
// LastFast
// Main iOS app view (Xcode 16.2 / iOS 18)

import SwiftUI
import SwiftData
import WidgetKit
import ActivityKit

// MARK: - Live Activity Feature Flag
let liveActivityEnabled = false

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    @State private var timer: Timer?
    @State private var liveActivityTimer: Timer?
    @State private var currentTime = Date()
    @State private var showingHistory = false
    @State private var showingGoalPicker = false
    @State private var showingStopConfirmation = false
    
    // Goal stored in UserDefaults (persists between fasts)
    @AppStorage("fastingGoalMinutes") private var savedGoalMinutes: Int = 720 // Default 12 hours
    
    private var activeFast: FastingSession? {
        sessions.first { $0.isActive }
    }
    
    private var currentDuration: TimeInterval {
        guard let fast = activeFast else { return 0 }
        return currentTime.timeIntervalSince(fast.startTime)
    }
    
    private var hours: Int {
        let remaining = remainingMinutes
        return remaining / 60
    }
    
    private var minutes: Int {
        let remaining = remainingMinutes
        return remaining % 60
    }
    
    private var remainingMinutes: Int {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    private var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    private var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    private var goalMet: Bool {
        guard let fast = activeFast, let goal = fast.goalMinutes else { return false }
        let elapsedMinutes = Int(currentDuration) / 60
        return elapsedMinutes >= goal
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: activeFast != nil ? [Color.orange.opacity(0.1), Color.orange.opacity(0.05)] : [Color(.systemBackground), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if activeFast != nil {
                        Spacer()
                        
                        // Main timer display (only when fasting)
                        timerDisplay
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                        
                        // Goal underneath progress bar
                        goalAndStartTimeView
                            .padding(.top, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        
                        Spacer()
                        
                        // Action button
                        actionButton
                    } else {
                        Spacer()
                        
                        // Goal setter and Start button centered
                        VStack(spacing: 24) {
                            goalSetterView
                                .transition(.opacity)
                            
                            actionButton
                        }
                        
                        Spacer()
                    }
                    
                    // Last fast / History button (anchored to bottom)
                    lastFastButton
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
                .padding()
                .animation(.easeInOut(duration: 0.4), value: activeFast != nil)
            }
            .onAppear {
                startTimer()
                if liveActivityEnabled {
                    resumeLiveActivityIfNeeded()
                }
            }
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
    
    // MARK: - Last Fast Button
    
    private var lastFast: FastingSession? {
        sessions.first { !$0.isActive }
    }
    
    private var lastFastButton: some View {
        Button(action: { showingHistory = true }) {
            if let last = lastFast {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last Fast")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                            
                            let hours = Int(last.duration) / 3600
                            let mins = (Int(last.duration) % 3600) / 60
                            HStack(spacing: 6) {
                                Text(formatDuration(hours: hours, minutes: mins))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(last.goalMet ? .green : .orange)
                                
                                if last.goalMinutes != nil {
                                    Image(systemName: last.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(last.goalMet ? .green : .red)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(last.startTime.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 4) {
                                Text("View History")
                                    .font(.subheadline)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                            .foregroundStyle(.blue)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 20)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.clock")
                    Text("View History")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Status Badge
    
    private var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(activeFast != nil ? (goalMet ? Color.green : Color.orange) : Color.gray)
                .frame(width: 10, height: 10)
            
            if goalMet {
                Text("Goal Reached!")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            } else {
                Text(activeFast != nil ? "Fasting" : "Not Fasting")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(activeFast != nil ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Timer Display
    
    private var progress: Double {
        guard let fast = activeFast, let goal = fast.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    private var timerDisplay: some View {
        VStack(spacing: 16) {
            Text(goalMet ? "You've fasted for" : "Keep fasting")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            if goalMet {
                // Show total elapsed time when goal is met
                if elapsedHours > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(elapsedHours)")
                            .font(.system(size: 110, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        Text("h")
                            .font(.system(size: 33, weight: .medium, design: .rounded))
                            .foregroundStyle(.green.opacity(0.7))
                        
                        Text("\(elapsedMins)")
                            .font(.system(size: 110, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        Text("m")
                            .font(.system(size: 33, weight: .medium, design: .rounded))
                            .foregroundStyle(.green.opacity(0.7))
                    }
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(elapsedMins)")
                            .font(.system(size: 110, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        
                        Text("m")
                            .font(.system(size: 33, weight: .medium, design: .rounded))
                            .foregroundStyle(.green.opacity(0.7))
                    }
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                }
            } else if hours > 0 {
                // Show hours and minutes countdown
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(hours)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    
                    Text("h")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.orange.opacity(0.7))
                    
                    Text("\(minutes)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    
                    Text("m")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.orange.opacity(0.7))
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            } else {
                // Show only minutes when less than 1 hour
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(minutes)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                    
                    Text("m")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.orange.opacity(0.7))
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
            
            // Progress bar (only show when goal not met)
            if !goalMet {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 16)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange)
                            .frame(width: geometry.size.width * progress, height: 16)
                    }
                }
                .frame(height: 16)
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Goal and Start Time View
    
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
    
    // MARK: - Goal Setter View
    
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
    
    // MARK: - Action Button
    
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
    
    // MARK: - Actions
    
    private func toggleFasting() {
        if activeFast != nil {
            showingStopConfirmation = true
        } else {
            let newSession = FastingSession(goalMinutes: savedGoalMinutes)
            modelContext.insert(newSession)
            try? modelContext.save()
            WidgetCenter.shared.reloadAllTimelines()
            
            // Save to UserDefaults for background task access
            let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
            defaults?.set(newSession.startTime.timeIntervalSince1970, forKey: "fastingStartTime")
            defaults?.set(savedGoalMinutes, forKey: "fastingGoalMinutes")
            defaults?.set(true, forKey: "isFasting")
            
            // Start Live Activity
            if liveActivityEnabled {
                startLiveActivity(startTime: newSession.startTime, goalMinutes: savedGoalMinutes)
            }
        }
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
            
            // End Live Activity
            if liveActivityEnabled {
                endLiveActivity()
            }
        }
    }
    
    // MARK: - Live Activity Management
    
    private func startLiveActivity(startTime: Date, goalMinutes: Int) {
        let authInfo = ActivityAuthorizationInfo()
        
        print("Live Activity Debug:")
        print("  - areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")
        print("  - frequentPushesEnabled: \(authInfo.frequentPushesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("  - Live Activities are NOT enabled!")
            return
        }
        
        let attributes = LastFastWidgetAttributes(
            startTime: startTime,
            goalMinutes: goalMinutes
        )
        
        let initialState = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: Int(Date().timeIntervalSince(startTime)),
            goalMet: false
        )
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("  - Live Activity started successfully! ID: \(activity.id)")
        } catch {
            print("  - Failed to start Live Activity: \(error)")
        }
    }
    
    private func updateLiveActivity() {
        guard let fast = activeFast else { return }
        
        let elapsed = Int(currentTime.timeIntervalSince(fast.startTime))
        let goalMet = fast.goalMinutes.map { elapsed >= $0 * 60 } ?? false
        
        let updatedState = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: elapsed,
            goalMet: goalMet
        )
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            for activity in Activity<LastFastWidgetAttributes>.activities {
                await activity.update(content)
            }
        }
    }
    
    private func endLiveActivity() {
        Task {
            for activity in Activity<LastFastWidgetAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
    
    private func resumeLiveActivityIfNeeded() {
        // If there's an active fast but no Live Activity, start one
        guard let fast = activeFast else {
            // No active fast, end any stale activities
            endLiveActivity()
            return
        }
        
        // Check if there's already an active Live Activity
        if Activity<LastFastWidgetAttributes>.activities.isEmpty {
            // Start a new Live Activity for the existing fast
            startLiveActivity(startTime: fast.startTime, goalMinutes: fast.goalMinutes ?? savedGoalMinutes)
        }
        
        // Update immediately
        if liveActivityEnabled {
            updateLiveActivity()
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        // UI timer - updates every second for in-app display
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [self] _ in
            DispatchQueue.main.async {
                self.currentTime = Date()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
        
        // Live Activity timer - updates every 60 seconds
        if liveActivityEnabled {
            liveActivityTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [self] _ in
                DispatchQueue.main.async {
                    self.updateLiveActivity()
                }
            }
            RunLoop.main.add(liveActivityTimer!, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        if liveActivityEnabled {
            liveActivityTimer?.invalidate()
            liveActivityTimer = nil
        }
    }
}

// MARK: - Duration Formatting Helper

func formatDuration(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

// MARK: - Goal Picker View

struct GoalPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goalMinutes: Int
    
    @State private var selectedHours: Int = 8
    @State private var selectedMinutes: Int = 0
    
    private var isValidGoal: Bool {
        selectedHours > 0 || selectedMinutes > 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("Set Your Fasting Goal")
                    .font(.headline)
                    .padding(.top, 24)
                
                // Hours stepper
                VStack(spacing: 8) {
                    Text("Hours")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Stepper(value: $selectedHours, in: 0...47) {
                        Text("\(selectedHours)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                }
                
                // Minutes stepper
                VStack(spacing: 8) {
                    Text("Minutes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Stepper(value: $selectedMinutes, in: 0...59) {
                        Text("\(selectedMinutes)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                }
                
                // Total display
                if isValidGoal {
                    Text("Total: \(formatDuration(hours: selectedHours, minutes: selectedMinutes))")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                } else {
                    Text("Goal must be at least 1 minute")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        goalMinutes = selectedHours * 60 + selectedMinutes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValidGoal)
                }
            }
            .onAppear {
                selectedHours = goalMinutes / 60
                selectedMinutes = goalMinutes % 60
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - History View Configuration

/// Set to `true` to show the graph view, `false` to show the simple list view
let useGraphHistoryView = false

// MARK: - History View

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \FastingSession.startTime, order: .reverse) private var sessions: [FastingSession]
    
    private var completedSessions: [FastingSession] {
        sessions.filter { !$0.isActive }
    }
    
    // Get sessions sorted by date for chart (oldest first)
    private var chartSessions: [FastingSession] {
        Array(completedSessions.reversed().suffix(14)) // Last 14 fasts
    }
    
    // Maximum duration for scaling (only actual fast durations, not goals)
    private var maxDuration: TimeInterval {
        chartSessions.max(by: { $0.duration < $1.duration })?.duration ?? 3600
    }
    
    @State private var selectedSession: FastingSession?
    
    var body: some View {
        NavigationStack {
            Group {
                if completedSessions.isEmpty {
                    ContentUnavailableView(
                        "No Fasting History",
                        systemImage: "clock.badge.questionmark",
                        description: Text("Complete your first fast to see it here")
                    )
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
                // Bar chart
                barChart
                    .padding(.top, 16)
                
                // Selected session details
                if let session = selectedSession {
                    selectedSessionCard(session: session)
                }
                
                // Summary stats
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
                            let hours = Int(session.duration) / 3600
                            let mins = (Int(session.duration) % 3600) / 60
                            
                            VStack(spacing: 2) {
                                // Duration label
                                Text(formatDuration(hours: hours, minutes: mins))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(session.goalMet ? .green : .red)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                
                                // Bar
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(session.goalMet ? Color.green : Color.red)
                                    .frame(width: barWidth, height: max(barHeight, 4))
                                    .opacity(selectedSession?.id == session.id ? 1.0 : 0.8)
                                    .scaleEffect(selectedSession?.id == session.id ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedSession?.id)
                                    .onTapGesture {
                                        withAnimation {
                                            if selectedSession?.id == session.id {
                                                selectedSession = nil
                                            } else {
                                                selectedSession = session
                                            }
                                        }
                                    }
                            }
                            .frame(height: chartHeight + 16, alignment: .bottom)
                        }
                    }
                    
                    // X-axis line
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 1)
                    
                    // X-axis labels (dates)
                    HStack(alignment: .top, spacing: 4) {
                        ForEach(chartSessions) { session in
                            Text(formatChartDate(session.startTime))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .frame(width: barWidth)
                                .lineLimit(1)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .frame(height: 260)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Selected Session Card
    
    private func selectedSessionCard(session: FastingSession) -> some View {
        let hours = Int(session.duration) / 3600
        let mins = (Int(session.duration) % 3600) / 60
        
        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.startTime.formatted(date: .long, time: .omitted))
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Text(format24HourTime(session.startTime))
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                        Text(session.endTime.map { format24HourTime($0) } ?? "—")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(formatDuration(hours: hours, minutes: mins))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(session.goalMet ? .green : .red)
                        
                        Image(systemName: session.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(session.goalMet ? .green : .red)
                    }
                    
                    if let goal = session.goalMinutes {
                        Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Delete button
            Button(role: .destructive) {
                withAnimation {
                    modelContext.delete(session)
                    try? modelContext.save()
                    selectedSession = nil
                }
            } label: {
                Label("Delete Fast", systemImage: "trash")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Stats Card
    
    private var statsCard: some View {
        let totalFasts = completedSessions.count
        let goalsReached = completedSessions.filter { $0.goalMet }.count
        let successRate = totalFasts > 0 ? Double(goalsReached) / Double(totalFasts) * 100 : 0
        let avgDuration = totalFasts > 0 ? completedSessions.reduce(0) { $0 + $1.duration } / Double(totalFasts) : 0
        let avgHours = Int(avgDuration) / 3600
        let avgMins = (Int(avgDuration) % 3600) / 60
        
        return VStack(spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatBox(title: "Total Fasts", value: "\(totalFasts)")
                StatBox(title: "Goals Met", value: "\(goalsReached)")
            }
            
            HStack(spacing: 16) {
                StatBox(title: "Success Rate", value: String(format: "%.0f%%", successRate))
                StatBox(title: "Avg Duration", value: formatDuration(hours: avgHours, minutes: avgMins))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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

// MARK: - History Row (kept for reference but no longer used)

struct FastingHistoryRow: View {
    let session: FastingSession
    
    private var hours: Int {
        Int(session.duration) / 3600
    }
    
    private var minutes: Int {
        (Int(session.duration) % 3600) / 60
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                    
                    // Goal status indicator
                    if session.goalMinutes != nil {
                        Image(systemName: session.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(session.goalMet ? .green : .red)
                            .font(.subheadline)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(format24HourTime(session.startTime))
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(session.endTime.map { format24HourTime($0) } ?? "—")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                // Show goal if set
                if let goal = session.goalMinutes {
                    Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            Text(formatDuration(hours: hours, minutes: minutes))
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(session.goalMet ? .green : .orange)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FastingSession.self, inMemory: true)
}
