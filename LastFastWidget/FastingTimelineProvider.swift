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
        // Sample placeholder data with history
        let sampleHistory = (0..<5).map { dayOffset in
            DayFastingData(
                date: Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!,
                totalFastedHours: Double.random(in: 12...18),
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
            recentHistory: sampleHistory
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
                    lastFastDuration: data.lastFastDuration,
                    lastFastGoalMet: data.lastFastGoalMet,
                    lastFastStartTime: data.lastFastStartTime,
                    lastFastEndTime: data.lastFastEndTime,
                    recentHistory: data.recentHistory
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
                lastFastDuration: data.lastFastDuration,
                lastFastGoalMet: data.lastFastGoalMet,
                lastFastStartTime: data.lastFastStartTime,
                lastFastEndTime: data.lastFastEndTime,
                recentHistory: data.recentHistory
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
            lastFastDuration: data.lastFastDuration,
            lastFastGoalMet: data.lastFastGoalMet,
            lastFastStartTime: data.lastFastStartTime,
            lastFastEndTime: data.lastFastEndTime,
            recentHistory: data.recentHistory
        )
    }
    
    private struct FastingData {
        let isActive: Bool
        let startTime: Date?
        let goalMinutes: Int?
        let lastFastDuration: TimeInterval?
        let lastFastGoalMet: Bool?
        let lastFastStartTime: Date?
        let lastFastEndTime: Date?
        let recentHistory: [DayFastingData]
    }
    
    private func fetchFastingData() -> FastingData {
        do {
            let schema = Schema([FastingSession.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<FastingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            let sessions = try context.fetch(descriptor)
            
            let activeFast = sessions.first { $0.isActive }
            let lastCompletedFast = sessions.first { !$0.isActive }
            
            // Calculate last 5 days history
            let recentHistory = calculateRecentHistory(from: sessions)
            
            return FastingData(
                isActive: activeFast != nil,
                startTime: activeFast?.startTime,
                goalMinutes: activeFast?.goalMinutes,
                lastFastDuration: lastCompletedFast?.duration,
                lastFastGoalMet: lastCompletedFast?.goalMet,
                lastFastStartTime: lastCompletedFast?.startTime,
                lastFastEndTime: lastCompletedFast?.endTime,
                recentHistory: recentHistory
            )
        } catch {
            return FastingData(
                isActive: false,
                startTime: nil,
                goalMinutes: nil,
                lastFastDuration: nil,
                lastFastGoalMet: nil,
                lastFastStartTime: nil,
                lastFastEndTime: nil,
                recentHistory: []
            )
        }
    }
    
    private func calculateRecentHistory(from sessions: [FastingSession]) -> [DayFastingData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get last 5 days (excluding today)
        var historyData: [DayFastingData] = []
        
        for dayOffset in 1...5 {
            guard let dayStart = calendar.date(byAdding: .day, value: -dayOffset, to: today),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            // Find all completed fasts that ended on this day
            let dayFasts = sessions.filter { session in
                guard !session.isActive, let endTime = session.endTime else { return false }
                return endTime >= dayStart && endTime < dayEnd
            }
            
            // Sum up total fasted hours for the day
            let totalSeconds = dayFasts.reduce(0.0) { $0 + $1.duration }
            let totalHours = totalSeconds / 3600.0
            
            // Check if any fast met its goal
            let anyGoalMet = dayFasts.contains { $0.goalMet }
            
            historyData.append(DayFastingData(
                date: dayStart,
                totalFastedHours: totalHours,
                goalMet: anyGoalMet
            ))
        }
        
        return historyData.reversed() // Oldest first for graph
    }
}
