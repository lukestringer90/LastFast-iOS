//
//  FastingTimelineProvider.swift
//  LastFastWidget
//
//  Timeline provider for fasting widgets
//

import WidgetKit
import SwiftData

struct FastingTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> FastingEntry {
        // Sample placeholder data with recent fasts
        let sampleFasts = (0..<5).map { offset in
            FastHistoryData(
                startDate: Calendar.current.date(byAdding: .day, value: -offset, to: Date())!,
                fastedHours: Double.random(in: 12...18),
                goalHours: 16.0,
                goalMet: Bool.random()
            )
        }
        
        return FastingEntry(
            date: Date(),
            isActive: true,
            startTime: Date().addingTimeInterval(-3600 * 4),
            goalMinutes: 480,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil,
            recentFasts: sampleFasts
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FastingEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let currentDate = Date()
        let data = fetchFastingData()
        
        var entries: [FastingEntry] = []
        
        if data.isActive {
            for minuteOffset in 0..<60 {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(minuteOffset * 60))
                let entry = FastingEntry(
                    date: entryDate,
                    isActive: data.isActive,
                    startTime: data.startTime,
                    goalMinutes: data.goalMinutes,
                    savedGoalMinutes: data.savedGoalMinutes,
                    lastFastDuration: data.lastFastDuration,
                    lastFastGoalMet: data.lastFastGoalMet,
                    lastFastStartTime: data.lastFastStartTime,
                    lastFastEndTime: data.lastFastEndTime,
                    recentFasts: data.recentFasts
                )
                entries.append(entry)
            }

            let refreshDate = currentDate.addingTimeInterval(60 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        } else {
            let entry = FastingEntry(
                date: currentDate,
                isActive: data.isActive,
                startTime: data.startTime,
                goalMinutes: data.goalMinutes,
                savedGoalMinutes: data.savedGoalMinutes,
                lastFastDuration: data.lastFastDuration,
                lastFastGoalMet: data.lastFastGoalMet,
                lastFastStartTime: data.lastFastStartTime,
                lastFastEndTime: data.lastFastEndTime,
                recentFasts: data.recentFasts
            )
            entries.append(entry)

            let refreshDate = currentDate.addingTimeInterval(15 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func createEntry(for date: Date) -> FastingEntry {
        let data = fetchFastingData()
        return FastingEntry(
            date: date,
            isActive: data.isActive,
            startTime: data.startTime,
            goalMinutes: data.goalMinutes,
            savedGoalMinutes: data.savedGoalMinutes,
            lastFastDuration: data.lastFastDuration,
            lastFastGoalMet: data.lastFastGoalMet,
            lastFastStartTime: data.lastFastStartTime,
            lastFastEndTime: data.lastFastEndTime,
            recentFasts: data.recentFasts
        )
    }
    
    private struct FastingData {
        let isActive: Bool
        let startTime: Date?
        let goalMinutes: Int?
        let savedGoalMinutes: Int
        let lastFastDuration: TimeInterval?
        let lastFastGoalMet: Bool?
        let lastFastStartTime: Date?
        let lastFastEndTime: Date?
        let recentFasts: [FastHistoryData]
    }
    
    private func fetchFastingData() -> FastingData {
        let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
        let savedGoal = defaults?.integer(forKey: "fastingGoalMinutes") ?? 720
        let savedGoalMinutes = savedGoal > 0 ? savedGoal : 720

        do {
            let schema = Schema([FastingSession.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.dev.stringer.lastfast")
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)

            let descriptor = FetchDescriptor<FastingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            let sessions = try context.fetch(descriptor)

            let activeFast = sessions.first { $0.isActive }
            let lastCompletedFast = sessions.first { !$0.isActive }

            // Get last 5 completed fasts
            let recentFasts = getRecentFasts(from: sessions)

            return FastingData(
                isActive: activeFast != nil,
                startTime: activeFast?.startTime,
                goalMinutes: activeFast?.goalMinutes,
                savedGoalMinutes: savedGoalMinutes,
                lastFastDuration: lastCompletedFast?.duration,
                lastFastGoalMet: lastCompletedFast?.goalMet,
                lastFastStartTime: lastCompletedFast?.startTime,
                lastFastEndTime: lastCompletedFast?.endTime,
                recentFasts: recentFasts
            )
        } catch {
            print("Widget: Failed to fetch fasting data: \(error)")
            return FastingData(
                isActive: false,
                startTime: nil,
                goalMinutes: nil,
                savedGoalMinutes: savedGoalMinutes,
                lastFastDuration: nil,
                lastFastGoalMet: nil,
                lastFastStartTime: nil,
                lastFastEndTime: nil,
                recentFasts: []
            )
        }
    }
    
    private func getRecentFasts(from sessions: [FastingSession]) -> [FastHistoryData] {
        // Get last 5 completed fasts
        let completedFasts = sessions.filter { !$0.isActive }.prefix(5)
        
        return completedFasts.reversed().map { session in
            FastHistoryData(
                startDate: session.startTime,
                fastedHours: session.duration / 3600.0,
                goalHours: Double(session.goalMinutes ?? 0) / 60.0,
                goalMet: session.goalMet
            )
        }
    }
}
