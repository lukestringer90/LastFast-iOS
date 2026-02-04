//
//  FastingEntryTests.swift
//  LastFastTests
//
//  Tests for FastingEntry widget data structure logic
//  Note: FastingEntry is in the widget target, so these tests verify
//  the data patterns and calculations used to populate entries.
//

import XCTest
@testable import LastFast

// MARK: - Fast History Data Tests

/// Tests for the FastHistoryData structure patterns used in widgets
final class FastHistoryDataTests: XCTestCase {

    func testFastHistoryData_Hashable() {
        // Given: Two identical history data items
        let data1 = makeFastHistoryData(startDate: Date(), fastedHours: 16.0, goalHours: 16.0, goalMet: true)
        let data2 = makeFastHistoryData(startDate: data1.startDate, fastedHours: 16.0, goalHours: 16.0, goalMet: true)

        // Then: Should be equal and have same hash
        XCTAssertEqual(data1, data2)
        XCTAssertEqual(data1.hashValue, data2.hashValue)
    }

    func testFastHistoryData_NotEqual_DifferentHours() {
        // Given: Two items with different fasted hours
        let date = Date()
        let data1 = makeFastHistoryData(startDate: date, fastedHours: 16.0, goalHours: 16.0, goalMet: true)
        let data2 = makeFastHistoryData(startDate: date, fastedHours: 14.0, goalHours: 16.0, goalMet: false)

        // Then: Should not be equal
        XCTAssertNotEqual(data1, data2)
    }

    func testFastHistoryData_NotEqual_DifferentGoalStatus() {
        // Given: Two items with different goal met status
        let date = Date()
        let data1 = makeFastHistoryData(startDate: date, fastedHours: 16.0, goalHours: 16.0, goalMet: true)
        let data2 = makeFastHistoryData(startDate: date, fastedHours: 16.0, goalHours: 16.0, goalMet: false)

        // Then: Should not be equal
        XCTAssertNotEqual(data1, data2)
    }

    // Helper to create history data without direct widget dependency
    private struct TestFastHistoryData: Hashable {
        let startDate: Date
        let fastedHours: Double
        let goalHours: Double
        let goalMet: Bool
    }

    private func makeFastHistoryData(startDate: Date, fastedHours: Double, goalHours: Double, goalMet: Bool) -> TestFastHistoryData {
        TestFastHistoryData(startDate: startDate, fastedHours: fastedHours, goalHours: goalHours, goalMet: goalMet)
    }
}

// MARK: - Fasting Entry Data Pattern Tests

/// Tests the data patterns used when creating FastingEntry objects
final class FastingEntryDataPatternTests: XCTestCase {

    func testEntryData_ActiveFasting() {
        // Given: Active fasting state
        let date = Date()
        let startTime = date.addingTimeInterval(-3600 * 4) // 4 hours ago
        let goalMinutes = 960

        // When: Creating entry data
        let entryData = EntryTestData(
            date: date,
            isActive: true,
            startTime: startTime,
            goalMinutes: goalMinutes,
            savedGoalMinutes: defaultFastingGoalMinutes,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil,
            recentFasts: []
        )

        // Then: Should have active state with correct data
        XCTAssertTrue(entryData.isActive)
        XCTAssertEqual(entryData.startTime, startTime)
        XCTAssertEqual(entryData.goalMinutes, goalMinutes)
    }

    func testEntryData_NotFasting() {
        // Given: Not fasting state
        let date = Date()
        let lastFastDuration: TimeInterval = 57600 // 16 hours

        // When: Creating entry data
        let entryData = EntryTestData(
            date: date,
            isActive: false,
            startTime: nil,
            goalMinutes: nil,
            savedGoalMinutes: defaultFastingGoalMinutes,
            lastFastDuration: lastFastDuration,
            lastFastGoalMet: true,
            lastFastStartTime: date.addingTimeInterval(-86400),
            lastFastEndTime: date.addingTimeInterval(-28800),
            recentFasts: []
        )

        // Then: Should have inactive state with last fast data
        XCTAssertFalse(entryData.isActive)
        XCTAssertNil(entryData.startTime)
        XCTAssertEqual(entryData.lastFastDuration, lastFastDuration)
        XCTAssertEqual(entryData.lastFastGoalMet, true)
    }

    func testEntryData_WithRecentFasts() {
        // Given: Recent fasts data
        let date = Date()
        let recentFasts = (0..<5).map { offset in
            TestRecentFast(
                startDate: Calendar.current.date(byAdding: .day, value: -offset, to: date)!,
                fastedHours: Double.random(in: 12...18),
                goalHours: 16.0,
                goalMet: offset % 2 == 0
            )
        }

        // When: Creating entry data with recent fasts
        let entryData = EntryTestData(
            date: date,
            isActive: false,
            startTime: nil,
            goalMinutes: nil,
            savedGoalMinutes: defaultFastingGoalMinutes,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil,
            recentFasts: recentFasts
        )

        // Then: Should have 5 recent fasts
        XCTAssertEqual(entryData.recentFasts.count, 5)
    }

    func testEntryData_DefaultSavedGoalMinutes() {
        // Given: Using default saved goal
        let entryData = EntryTestData(
            date: Date(),
            isActive: false,
            startTime: nil,
            goalMinutes: nil,
            savedGoalMinutes: defaultFastingGoalMinutes,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil,
            recentFasts: []
        )

        // Then: Should default to 960 minutes (16 hours)
        XCTAssertEqual(entryData.savedGoalMinutes, 960)
    }

    // Test helper structures
    private struct EntryTestData {
        let date: Date
        let isActive: Bool
        let startTime: Date?
        let goalMinutes: Int?
        let savedGoalMinutes: Int
        let lastFastDuration: TimeInterval?
        let lastFastGoalMet: Bool?
        let lastFastStartTime: Date?
        let lastFastEndTime: Date?
        let recentFasts: [TestRecentFast]
    }

    private struct TestRecentFast {
        let startDate: Date
        let fastedHours: Double
        let goalHours: Double
        let goalMet: Bool
    }
}

// MARK: - Entry Duration Calculation Tests

/// Tests duration calculations for widget entry display
final class EntryDurationCalculationTests: XCTestCase {

    func testDurationFromStartTime_4Hours() {
        // Given: A start time 4 hours ago
        let startTime = Date().addingTimeInterval(-3600 * 4)

        // When: Calculating duration
        let duration = Date().timeIntervalSince(startTime)

        // Then: Should be approximately 4 hours
        XCTAssertEqual(duration, 14400, accuracy: 1)
    }

    func testDurationToHoursConversion() {
        // Given: A duration of 16 hours
        let duration: TimeInterval = 57600

        // When: Converting to hours (as done for FastHistoryData.fastedHours)
        let fastedHours = duration / 3600.0

        // Then: Should be 16.0
        XCTAssertEqual(fastedHours, 16.0, accuracy: 0.01)
    }

    func testGoalMinutesToHoursConversion() {
        // Given: Goal in minutes
        let goalMinutes = 960

        // When: Converting to hours (as done for FastHistoryData.goalHours)
        let goalHours = Double(goalMinutes) / 60.0

        // Then: Should be 16.0
        XCTAssertEqual(goalHours, 16.0, accuracy: 0.01)
    }

    func testProgressCalculation_Halfway() {
        // Given: 8 hours elapsed out of 16 hour goal
        let duration: TimeInterval = 28800
        let goalMinutes = 960

        // When: Calculating progress
        let goalSeconds = Double(goalMinutes * 60)
        let progress = min(duration / goalSeconds, 1.0)

        // Then: Should be 50%
        XCTAssertEqual(progress, 0.5, accuracy: 0.01)
    }

    func testProgressCalculation_Complete() {
        // Given: 18 hours elapsed out of 16 hour goal
        let duration: TimeInterval = 64800
        let goalMinutes = 960

        // When: Calculating progress (capped at 1.0)
        let goalSeconds = Double(goalMinutes * 60)
        let progress = min(duration / goalSeconds, 1.0)

        // Then: Should be capped at 100%
        XCTAssertEqual(progress, 1.0, accuracy: 0.01)
    }
}

// MARK: - Recent Fasts Processing Tests

/// Tests the processing of recent fasts for widget display
final class RecentFastsProcessingTests: XCTestCase {

    func testFilterCompletedFasts() {
        // Given: A mix of active and completed sessions
        let sessions = [
            MockSession(isActive: true, duration: 0),
            MockSession(isActive: false, duration: 57600),
            MockSession(isActive: false, duration: 50400),
            MockSession(isActive: false, duration: 43200)
        ]

        // When: Filtering to completed only
        let completedFasts = sessions.filter { !$0.isActive }

        // Then: Should have 3 completed fasts
        XCTAssertEqual(completedFasts.count, 3)
        XCTAssertTrue(completedFasts.allSatisfy { !$0.isActive })
    }

    func testLimitToFiveFasts() {
        // Given: More than 5 completed sessions
        let sessions = (0..<10).map { _ in
            MockSession(isActive: false, duration: Double.random(in: 28800...72000))
        }

        // When: Taking prefix of 5
        let recentFasts = Array(sessions.prefix(5))

        // Then: Should have exactly 5
        XCTAssertEqual(recentFasts.count, 5)
    }

    func testReverseFastsForChronologicalOrder() {
        // Given: Fasts sorted by most recent first
        let dates = (0..<5).map { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())!
        }

        // When: Reversing for chronological display
        let chronological = dates.reversed()

        // Then: Oldest should be first
        let chronologicalArray = Array(chronological)
        XCTAssertLessThan(chronologicalArray[0], chronologicalArray[4])
    }

    func testConvertSessionToHistoryData() {
        // Given: A completed session
        let session = MockSession(
            isActive: false,
            duration: 57600, // 16 hours
            startTime: Date().addingTimeInterval(-86400),
            goalMinutes: 960
        )

        // When: Converting to history data format
        let fastedHours = session.duration / 3600.0
        let goalHours = Double(session.goalMinutes ?? 0) / 60.0
        let goalMet = session.duration >= Double((session.goalMinutes ?? 0) * 60)

        // Then: Should have correct values
        XCTAssertEqual(fastedHours, 16.0, accuracy: 0.01)
        XCTAssertEqual(goalHours, 16.0, accuracy: 0.01)
        XCTAssertTrue(goalMet)
    }

    private struct MockSession {
        let isActive: Bool
        let duration: TimeInterval
        var startTime: Date = Date()
        var goalMinutes: Int? = nil
    }
}
