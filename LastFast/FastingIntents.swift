// FastingIntents.swift
// LastFast
// App Intents for Siri integration

import AppIntents
import SwiftData
import WidgetKit

// MARK: - Time Formatting Helper

func format24HourTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

// MARK: - Start Fasting Intent

struct StartFastingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Fasting"
    static var description = IntentDescription("Start tracking a new fasting session")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(
            for: FastingSession.self,
            configurations: ModelConfiguration(
                schema: Schema([FastingSession.self]),
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
        )
        
        let context = container.mainContext
        
        // Check if already fasting
        let descriptor = FetchDescriptor<FastingSession>(
            predicate: #Predicate { $0.endTime == nil }
        )
        let activeSessions = try context.fetch(descriptor)
        
        if !activeSessions.isEmpty {
            return .result(dialog: "You're already fasting. Your fast started at \(format24HourTime(activeSessions.first!.startTime)).")
        }
        
        // Start new fast with default goal
        let newSession = FastingSession(goalMinutes: defaultFastingGoalMinutes)
        context.insert(newSession)
        try context.save()
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result(dialog: "Started your fast. Good luck!")
    }
}

// MARK: - Stop Fasting Intent

struct StopFastingIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Fasting"
    static var description = IntentDescription("Stop the current fasting session")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(
            for: FastingSession.self,
            configurations: ModelConfiguration(
                schema: Schema([FastingSession.self]),
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
        )
        
        let context = container.mainContext
        
        // Find active fast
        let descriptor = FetchDescriptor<FastingSession>(
            predicate: #Predicate { $0.endTime == nil }
        )
        let activeSessions = try context.fetch(descriptor)
        
        guard let activeFast = activeSessions.first else {
            return .result(dialog: "You're not currently fasting.")
        }
        
        // Calculate duration for confirmation message
        let hours = Int(activeFast.duration) / 3600
        let minutes = (Int(activeFast.duration) % 3600) / 60
        let durationText = hours > 0 ? "\(hours) hours and \(minutes) minutes" : "\(minutes) minutes"
        
        // Ask for confirmation
        try await requestConfirmation(
            result: .result(dialog: "You've been fasting for \(durationText). Do you want to stop?")
        )
        
        // User confirmed - stop the fast
        let goalMet = activeFast.goalMet
        activeFast.stop()
        try context.save()
        
        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()
        
        if goalMet {
            return .result(dialog: "Congratulations! You fasted for \(durationText) and reached your goal!")
        } else {
            return .result(dialog: "You fasted for \(durationText).")
        }
    }
}

// MARK: - Check Fasting Status Intent

struct CheckFastingStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Fasting Status"
    static var description = IntentDescription("Check how long you've been fasting")
    
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(
            for: FastingSession.self,
            configurations: ModelConfiguration(
                schema: Schema([FastingSession.self]),
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
        )
        
        let context = container.mainContext
        
        // Find active fast
        let descriptor = FetchDescriptor<FastingSession>(
            predicate: #Predicate { $0.endTime == nil }
        )
        let activeSessions = try context.fetch(descriptor)
        
        guard let activeFast = activeSessions.first else {
            return .result(dialog: "You're not currently fasting.")
        }
        
        let hours = Int(activeFast.duration) / 3600
        let minutes = (Int(activeFast.duration) % 3600) / 60
        
        let durationText: String
        if hours > 0 && minutes > 0 {
            durationText = "\(hours) hours and \(minutes) minutes"
        } else if hours > 0 {
            durationText = "\(hours) hours"
        } else {
            durationText = "\(minutes) minutes"
        }
        
        // Check goal progress
        if let goal = activeFast.goalMinutes {
            let goalHours = goal / 60
            if activeFast.goalMet {
                return .result(dialog: "You've been fasting for \(durationText). You've reached your \(goalHours) hour goal!")
            } else {
                let remainingMinutes = goal - (hours * 60 + minutes)
                let remainingHours = remainingMinutes / 60
                let remainingMins = remainingMinutes % 60
                let remainingText = remainingHours > 0 ? "\(remainingHours) hours and \(remainingMins) minutes" : "\(remainingMins) minutes"
                return .result(dialog: "You've been fasting for \(durationText). You have \(remainingText) left to reach your goal.")
            }
        }
        
        return .result(dialog: "You've been fasting for \(durationText).")
    }
}

// MARK: - App Shortcuts Provider

struct FastingShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFastingIntent(),
            phrases: [
                "Start a new fast in \(.applicationName)",
                "Start a new fast",
                "Start fasting in \(.applicationName)",
                "Start fasting",
                "Start my fast",
                "Begin fasting",
                "Begin my fast"
            ],
            shortTitle: "Start Fasting",
            systemImageName: "play.fill"
        )
        
        AppShortcut(
            intent: StopFastingIntent(),
            phrases: [
                "Stop my fast in \(.applicationName)",
                "Stop my fast",
                "Stop fasting",
                "End my fast",
                "End fasting",
                "Break my fast",
                "Finish fasting"
            ],
            shortTitle: "Stop Fasting",
            systemImageName: "stop.fill"
        )
        
        AppShortcut(
            intent: CheckFastingStatusIntent(),
            phrases: [
                "How long have I been fasting in \(.applicationName)",
                "How long have I been fasting",
                "How long have I fasted",
                "Check my fasting status",
                "Check my fast",
                "Fasting status",
                "Am I fasting"
            ],
            shortTitle: "Fast Status",
            systemImageName: "clock"
        )
    }
}
