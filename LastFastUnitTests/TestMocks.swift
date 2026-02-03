//
//  TestMocks.swift
//  LastFastTests
//
//  Shared mock dependencies for testing
//

import Foundation
@testable import LastFast

/// Mock UserDefaults for testing without affecting real storage
final class MockUserDefaults {
    private var storage: [String: Any] = [:]
    
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
    
    func object(forKey key: String) -> Any? {
        return storage[key]
    }
    
    func double(forKey key: String) -> Double {
        return storage[key] as? Double ?? 0
    }
    
    func integer(forKey key: String) -> Int {
        return storage[key] as? Int ?? 0
    }
    
    func bool(forKey key: String) -> Bool {
        return storage[key] as? Bool ?? false
    }
    
    func removeObject(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    func reset() {
        storage.removeAll()
    }
}

/// Mock Date provider for deterministic testing
struct MockDateProvider {
    static var currentDate: Date = Date()
    
    static func now() -> Date {
        return currentDate
    }
    
    static func reset() {
        currentDate = Date()
    }
    
    static func setDate(_ date: Date) {
        currentDate = date
    }
    
    static func advanceBy(seconds: TimeInterval) {
        currentDate = currentDate.addingTimeInterval(seconds)
    }
    
    static func advanceBy(minutes: Int) {
        advanceBy(seconds: TimeInterval(minutes * 60))
    }
    
    static func advanceBy(hours: Int) {
        advanceBy(seconds: TimeInterval(hours * 3600))
    }
}

// MARK: - Test Date Helpers

/// Helper for creating dates with specific components for testing
struct TestDateBuilder {
    /// Creates a date with specific hour and minute on a fixed day
    /// - Parameters:
    ///   - hour: Hour (0-23)
    ///   - minute: Minute (0-59)
    ///   - day: Day of month (default: 15)
    ///   - month: Month (default: 1)
    ///   - year: Year (default: 2024)
    /// - Returns: A Date with the specified components
    static func date(
        hour: Int,
        minute: Int,
        day: Int = 15,
        month: Int = 1,
        year: Int = 2024
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components)!
    }

    /// Creates a date relative to now
    /// - Parameters:
    ///   - hoursAgo: Hours before now (positive = past)
    ///   - minutesAgo: Minutes before now (positive = past)
    ///   - secondsAgo: Seconds before now (positive = past)
    /// - Returns: A Date offset from now
    static func dateAgo(
        hours: Int = 0,
        minutes: Int = 0,
        seconds: Int = 0
    ) -> Date {
        let totalSeconds = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        return Date().addingTimeInterval(-totalSeconds)
    }
}

// MARK: - Test Session Factory

/// Factory for creating FastingSession instances in tests
enum TestSessionFactory {
    /// Creates a completed session with specified duration
    /// - Parameters:
    ///   - durationMinutes: Duration of the fast in minutes
    ///   - goalMinutes: Optional goal in minutes
    /// - Returns: A stopped FastingSession with the specified duration
    static func completedSession(
        durationMinutes: Int,
        goalMinutes: Int? = nil
    ) -> FastingSession {
        let startTime = Date().addingTimeInterval(-TimeInterval(durationMinutes * 60))
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        session.stop()
        return session
    }

    /// Creates an active session started a certain time ago
    /// - Parameters:
    ///   - minutesAgo: How many minutes ago the session started
    ///   - goalMinutes: Optional goal in minutes
    /// - Returns: An active FastingSession
    static func activeSession(
        startedMinutesAgo: Int,
        goalMinutes: Int? = nil
    ) -> FastingSession {
        let startTime = Date().addingTimeInterval(-TimeInterval(startedMinutesAgo * 60))
        return FastingSession(startTime: startTime, goalMinutes: goalMinutes)
    }

    /// Creates a session that has just met its goal
    /// - Parameter goalMinutes: The goal in minutes
    /// - Returns: An active session that has exactly met its goal
    static func sessionAtGoal(goalMinutes: Int) -> FastingSession {
        let startTime = Date().addingTimeInterval(-TimeInterval(goalMinutes * 60))
        return FastingSession(startTime: startTime, goalMinutes: goalMinutes)
    }

    /// Creates a session with typical 16-hour goal
    /// - Parameter startedHoursAgo: How many hours ago the session started
    /// - Returns: An active FastingSession with default 16-hour goal
    static func typicalFast(startedHoursAgo: Int) -> FastingSession {
        let startTime = Date().addingTimeInterval(-TimeInterval(startedHoursAgo * 3600))
        return FastingSession(startTime: startTime, goalMinutes: 960)
    }
}
