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
        FastingEntry(
            date: Date(),
            isActive: true,
            startTime: Date().addingTimeInterval(-3600 * 4),
            goalMinutes: 480,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil
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
                    lastFastEndTime: data.lastFastEndTime
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
                lastFastEndTime: data.lastFastEndTime
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
            lastFastEndTime: data.lastFastEndTime
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
            
            return FastingData(
                isActive: activeFast != nil,
                startTime: activeFast?.startTime,
                goalMinutes: activeFast?.goalMinutes,
                lastFastDuration: lastCompletedFast?.duration,
                lastFastGoalMet: lastCompletedFast?.goalMet,
                lastFastStartTime: lastCompletedFast?.startTime,
                lastFastEndTime: lastCompletedFast?.endTime
            )
        } catch {
            return FastingData(
                isActive: false,
                startTime: nil,
                goalMinutes: nil,
                lastFastDuration: nil,
                lastFastGoalMet: nil,
                lastFastStartTime: nil,
                lastFastEndTime: nil
            )
        }
    }
}
