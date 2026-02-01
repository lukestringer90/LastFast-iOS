// FastingIntents.swift
// LastFast
// App Intents for Siri integration

import AppIntents
import SwiftData
import WidgetKit

// MARK: - Start Fasting Intent

struct StartFastingIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a fast"
    static var description = IntentDescription("Start tracking a new fasting session with your default goal or a custom duration")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Duration (hours)", description: "Fast duration in hours (e.g., 16 or 18.5). Leave empty to use your default goal.")
    var durationHours: Double?

    static var parameterSummary: some ParameterSummary {
        Summary("Start a fast for \(\.$durationHours) hours")
    }

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

        // Determine goal minutes from parameter or saved settings
        let goalMinutes: Int
        let goalDescription: String

        if let hours = durationHours {
            // User specified duration in hours
            goalMinutes = Int(hours * 60)
            let wholeHours = Int(hours)
            let mins = Int((hours - Double(wholeHours)) * 60)
            if mins > 0 {
                goalDescription = "\(wholeHours) hours and \(mins) minutes"
            } else {
                goalDescription = "\(wholeHours) hours"
            }
        } else {
            // Use saved goal or default
            let savedGoal = UserDefaults.standard.integer(forKey: "fastingGoalMinutes")
            goalMinutes = savedGoal > 0 ? savedGoal : defaultFastingGoalMinutes
            let hours = goalMinutes / 60
            let mins = goalMinutes % 60
            if mins > 0 {
                goalDescription = "\(hours) hours and \(mins) minutes"
            } else {
                goalDescription = "\(hours) hours"
            }
        }

        let newSession = FastingSession(goalMinutes: goalMinutes)
        context.insert(newSession)
        try context.save()

        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Started your \(goalDescription) fast. Good luck!")
    }
}

// MARK: - Start Fasting With End Time Intent

struct StartFastingWithEndTimeIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a fast with an end time"
    static var description = IntentDescription("Start tracking a new fasting session that ends at a specific time")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "End Time", description: "When the fast should end")
    var endTime: Date

    static var parameterSummary: some ParameterSummary {
        Summary("Start a fast until \(\.$endTime)")
    }

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

        // Calculate minutes from now until end time
        let minutesUntilEnd = Int(endTime.timeIntervalSinceNow / 60)
        if minutesUntilEnd <= 0 {
            return .result(dialog: "The end time must be in the future.")
        }

        let newSession = FastingSession(goalMinutes: minutesUntilEnd)
        context.insert(newSession)
        try context.save()

        // Refresh widgets
        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Started your fast until \(format24HourTime(endTime)). Good luck!")
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
                "Start fasting in \(.applicationName)",
                "Start my fast in \(.applicationName)",
                "Begin fasting in \(.applicationName)",
                "Begin my fast in \(.applicationName)"
            ],
            shortTitle: "Start a fast",
            systemImageName: "play.fill"
        )

        AppShortcut(
            intent: StartFastingWithEndTimeIntent(),
            phrases: [
                "Start a fast with an end time in \(.applicationName)",
                "Start a timed fast in \(.applicationName)"
            ],
            shortTitle: "Fast until time",
            systemImageName: "clock.badge.fill"
        )

        AppShortcut(
            intent: StopFastingIntent(),
            phrases: [
                "Stop my fast in \(.applicationName)",
                "Stop fasting in \(.applicationName)",
                "End my fast in \(.applicationName)",
                "End fasting in \(.applicationName)",
                "Break my fast in \(.applicationName)",
                "Finish fasting in \(.applicationName)"
            ],
            shortTitle: "Stop Fasting",
            systemImageName: "stop.fill"
        )

        AppShortcut(
            intent: CheckFastingStatusIntent(),
            phrases: [
                "How long have I been fasting in \(.applicationName)",
                "How long have I fasted in \(.applicationName)",
                "Check my fasting status in \(.applicationName)",
                "Check my fast in \(.applicationName)",
                "Fasting status in \(.applicationName)",
                "Am I fasting in \(.applicationName)"
            ],
            shortTitle: "Fast Status",
            systemImageName: "clock"
        )
    }
}
