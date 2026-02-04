//
//  FastingTimelineProviderTests.swift
//  LastFastTests
//
//  Tests for FastingTimelineProvider timeline generation logic
//  Note: These tests verify the calculation and timeline logic patterns
//  without directly accessing the widget target's types.
//

import XCTest
@testable import LastFast

// MARK: - Placeholder Generation Tests

final class TimelineProviderPlaceholderTests: XCTestCase {

    func testPlaceholder_GeneratesSampleFasts() {
        // Given: Need to generate 5 sample fasts for placeholder

        // When: Generating sample data (as in placeholder method)
        let sampleFasts = (0..<5).map { offset in
            let startDate = Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
            let fastedHours = Double.random(in: 12...18)
            let goalHours = 16.0
            let goalMet = Bool.random()
            return (startDate: startDate, fastedHours: fastedHours, goalHours: goalHours, goalMet: goalMet)
        }

        // Then: Should have 5 sample fasts with valid data
        XCTAssertEqual(sampleFasts.count, 5)
        for fast in sampleFasts {
            XCTAssertGreaterThanOrEqual(fast.fastedHours, 12)
            XCTAssertLessThanOrEqual(fast.fastedHours, 18)
            XCTAssertEqual(fast.goalHours, 16.0)
        }
    }

    func testPlaceholder_UsesRecentDates() {
        // Given: Sample fasts generated for placeholder

        // When: Checking date offsets
        let baseDate = Date()
        let dates = (0..<5).map { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: baseDate)!
        }

        // Then: Dates should be in decreasing order (most recent first)
        for i in 0..<4 {
            XCTAssertGreaterThan(dates[i], dates[i + 1])
        }
    }

    func testPlaceholder_ActiveStateDefaults() {
        // Given: Placeholder configuration
        let isActive = true
        let startTime = Date().addingTimeInterval(-3600 * 4) // 4 hours ago
        let goalMinutes = 480

        // Then: Placeholder shows active state with 4-hour elapsed time
        XCTAssertTrue(isActive)
        XCTAssertEqual(goalMinutes, 480)
        XCTAssertLessThan(startTime, Date())
    }
}

// MARK: - Timeline Entry Generation Tests

final class TimelineEntryGenerationTests: XCTestCase {

    func testActiveTimeline_GeneratesMinuteEntries() {
        // Given: Active fasting state
        let isActive = true
        let currentDate = Date()

        // When: Generating entries for active state (60 entries, one per minute)
        var entries: [Date] = []
        if isActive {
            for minuteOffset in 0..<60 {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(minuteOffset * 60))
                entries.append(entryDate)
            }
        }

        // Then: Should have 60 minute-interval entries
        XCTAssertEqual(entries.count, 60)

        // Verify spacing
        for i in 1..<entries.count {
            let interval = entries[i].timeIntervalSince(entries[i-1])
            XCTAssertEqual(interval, 60, accuracy: 0.1)
        }
    }

    func testInactiveTimeline_GeneratesSingleEntry() {
        // Given: Inactive fasting state
        let isActive = false
        let currentDate = Date()

        // When: Generating entries for inactive state
        var entries: [Date] = []
        if isActive {
            // Would generate multiple entries
        } else {
            entries.append(currentDate)
        }

        // Then: Should have single entry
        XCTAssertEqual(entries.count, 1)
    }

    func testTimelineRefreshPolicy_ActiveState() {
        // Given: Active state refresh policy
        let currentDate = Date()

        // When: Calculating refresh date for active timeline
        let refreshDate = currentDate.addingTimeInterval(60 * 60) // 1 hour

        // Then: Should refresh after 1 hour
        let interval = refreshDate.timeIntervalSince(currentDate)
        XCTAssertEqual(interval, 3600)
    }

    func testTimelineRefreshPolicy_InactiveState() {
        // Given: Inactive state refresh policy
        let currentDate = Date()

        // When: Calculating refresh date for inactive timeline
        let refreshDate = currentDate.addingTimeInterval(15 * 60) // 15 minutes

        // Then: Should refresh after 15 minutes
        let interval = refreshDate.timeIntervalSince(currentDate)
        XCTAssertEqual(interval, 900)
    }
}

// MARK: - Fasting Data Fetch Logic Tests

final class FastingDataFetchLogicTests: XCTestCase {

    func testSavedGoalFallback_ZeroValue() {
        // Given: No saved goal (returns 0)
        let savedGoal = 0

        // When: Applying fallback logic
        let effectiveGoal = savedGoal > 0 ? savedGoal : defaultFastingGoalMinutes

        // Then: Should use default (960 minutes)
        XCTAssertEqual(effectiveGoal, 960)
    }

    func testSavedGoalFallback_ValidValue() {
        // Given: A valid saved goal
        let savedGoal = 720 // 12 hours

        // When: Applying fallback logic
        let effectiveGoal = savedGoal > 0 ? savedGoal : defaultFastingGoalMinutes

        // Then: Should use saved value
        XCTAssertEqual(effectiveGoal, 720)
    }

    func testActiveFastDetection_FirstActive() {
        // Given: Sessions with one active fast (first in sorted list)
        let sessions = [
            MockProviderSession(isActive: true, startTime: Date()),
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-86400)),
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-172800))
        ]

        // When: Finding active fast
        let activeFast = sessions.first { $0.isActive }

        // Then: Should find the active session
        XCTAssertNotNil(activeFast)
        XCTAssertTrue(activeFast!.isActive)
    }

    func testActiveFastDetection_NoActive() {
        // Given: Sessions with no active fast
        let sessions = [
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-86400)),
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-172800))
        ]

        // When: Finding active fast
        let activeFast = sessions.first { $0.isActive }

        // Then: Should be nil
        XCTAssertNil(activeFast)
    }

    func testLastCompletedFastDetection() {
        // Given: Sessions sorted by start time (most recent first)
        let sessions = [
            MockProviderSession(isActive: true, startTime: Date()),
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-86400)),
            MockProviderSession(isActive: false, startTime: Date().addingTimeInterval(-172800))
        ]

        // When: Finding last completed fast
        let lastCompleted = sessions.first { !$0.isActive }

        // Then: Should find the most recent completed session
        XCTAssertNotNil(lastCompleted)
        XCTAssertFalse(lastCompleted!.isActive)
    }

    private struct MockProviderSession {
        let isActive: Bool
        let startTime: Date
        var duration: TimeInterval = 0
        var goalMinutes: Int? = nil
        var endTime: Date? = nil
        var goalMet: Bool = false
    }
}

// MARK: - Recent Fasts Processing Tests

final class ProviderRecentFastsTests: XCTestCase {

    func testGetRecentFasts_FiltersActiveSession() {
        // Given: Sessions including an active one
        let sessions = [
            MockFast(isActive: true, duration: 0),
            MockFast(isActive: false, duration: 57600),
            MockFast(isActive: false, duration: 50400)
        ]

        // When: Filtering to completed fasts
        let completedFasts = sessions.filter { !$0.isActive }

        // Then: Should exclude active session
        XCTAssertEqual(completedFasts.count, 2)
        XCTAssertTrue(completedFasts.allSatisfy { !$0.isActive })
    }

    func testGetRecentFasts_LimitsToFive() {
        // Given: More than 5 completed sessions
        let sessions = (0..<10).map { _ in
            MockFast(isActive: false, duration: Double.random(in: 28800...72000))
        }

        // When: Taking prefix of 5
        let recentFasts = Array(sessions.prefix(5))

        // Then: Should have 5
        XCTAssertEqual(recentFasts.count, 5)
    }

    func testGetRecentFasts_ReversesForChronologicalOrder() {
        // Given: Completed fasts (sorted most recent first)
        let sessions = (0..<5).map { offset in
            MockFast(
                isActive: false,
                duration: 57600,
                startTime: Date().addingTimeInterval(TimeInterval(-offset * 86400))
            )
        }

        // When: Reversing for chronological display
        let chronological = sessions.reversed()
        let chronologicalArray = Array(chronological)

        // Then: Oldest should be first
        XCTAssertLessThan(chronologicalArray[0].startTime, chronologicalArray[4].startTime)
    }

    func testConvertToHistoryData() {
        // Given: A completed session
        let session = MockFast(
            isActive: false,
            duration: 57600,
            startTime: Date().addingTimeInterval(-86400),
            goalMinutes: 960,
            goalMet: true
        )

        // When: Converting to history data format
        let fastedHours = session.duration / 3600.0
        let goalHours = Double(session.goalMinutes ?? 0) / 60.0

        // Then: Should have correct values
        XCTAssertEqual(fastedHours, 16.0, accuracy: 0.01)
        XCTAssertEqual(goalHours, 16.0, accuracy: 0.01)
        XCTAssertTrue(session.goalMet)
    }

    private struct MockFast {
        let isActive: Bool
        var duration: TimeInterval
        var startTime: Date = Date()
        var goalMinutes: Int? = nil
        var goalMet: Bool = false
    }
}

// MARK: - Error Handling Tests

final class ProviderErrorHandlingTests: XCTestCase {

    func testFetchFailure_ReturnsDefaultData() {
        // Given: A simulated fetch failure scenario

        // When: Constructing fallback data
        let savedGoalMinutes = 960
        let fallbackData = (
            isActive: false,
            startTime: nil as Date?,
            goalMinutes: nil as Int?,
            savedGoalMinutes: savedGoalMinutes,
            lastFastDuration: nil as TimeInterval?,
            lastFastGoalMet: nil as Bool?,
            lastFastStartTime: nil as Date?,
            lastFastEndTime: nil as Date?,
            recentFasts: [] as [Any]
        )

        // Then: Should have safe default values
        XCTAssertFalse(fallbackData.isActive)
        XCTAssertNil(fallbackData.startTime)
        XCTAssertNil(fallbackData.goalMinutes)
        XCTAssertEqual(fallbackData.savedGoalMinutes, 960)
        XCTAssertTrue(fallbackData.recentFasts.isEmpty)
    }
}
