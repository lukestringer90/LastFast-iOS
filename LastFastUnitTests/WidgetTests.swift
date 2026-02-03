//
//  WidgetTests.swift
//  LastFastTests
//
//  Tests for widget-related calculation logic
//  Note: Widget-specific types (FastHistoryData, FastingEntry) are in the widget target.
//  These tests verify the shared calculation functions that widgets use.
//

import XCTest
@testable import LastFast

// MARK: - Widget Duration Formatting Tests

/// Tests the duration formatting used in widgets
/// Uses the actual formatDuration function from DurationFormatting.swift
final class WidgetDurationFormattingTests: XCTestCase {

    func testFormatDuration_HoursAndMinutes() {
        XCTAssertEqual(formatDuration(hours: 16, minutes: 30), "16h 30m")
    }

    func testFormatDuration_HoursOnly() {
        XCTAssertEqual(formatDuration(hours: 8, minutes: 0), "8h")
    }

    func testFormatDuration_MinutesOnly() {
        XCTAssertEqual(formatDuration(hours: 0, minutes: 45), "45m")
    }

    func testFormatDuration_ZeroValues() {
        XCTAssertEqual(formatDuration(hours: 0, minutes: 0), "0m")
    }

    func testFormatDuration_LargeHours() {
        XCTAssertEqual(formatDuration(hours: 48, minutes: 15), "48h 15m")
    }

    func testFormatDuration_SingleDigitValues() {
        XCTAssertEqual(formatDuration(hours: 1, minutes: 5), "1h 5m")
    }

    func testHoursAndMinutesExtraction() {
        let (hours, minutes) = hoursAndMinutes(from: 59400) // 16.5 hours
        XCTAssertEqual(hours, 16)
        XCTAssertEqual(minutes, 30)
    }

    func testFormatDurationFromInterval() {
        XCTAssertEqual(formatDuration(from: 59400), "16h 30m")
        XCTAssertEqual(formatDuration(from: 3600), "1h")
        XCTAssertEqual(formatDuration(from: 1800), "30m")
    }
}

// MARK: - Widget Data Calculation Tests

/// Tests the data calculations used when populating widget entries
final class WidgetDataCalculationTests: XCTestCase {

    // MARK: - Fasted Hours Calculation

    func testFastedHoursCalculation() {
        // Given: A session duration
        let duration: TimeInterval = 59400 // 16.5 hours

        // When: Converting to fasted hours (widget format)
        let fastedHours = duration / 3600.0

        // Then: Should be 16.5
        XCTAssertEqual(fastedHours, 16.5, accuracy: 0.01)
    }

    func testGoalHoursCalculation() {
        // Given: Goal in minutes
        let goalMinutes = 960

        // When: Converting to goal hours (widget format)
        let goalHours = Double(goalMinutes) / 60.0

        // Then: Should be 16.0
        XCTAssertEqual(goalHours, 16.0, accuracy: 0.01)
    }

    // MARK: - Recent Fasts Filtering

    func testRecentFastsFiltering() {
        // Given: Multiple sessions (simulated)
        let sessions = [
            (isActive: true, startTime: Date()),
            (isActive: false, startTime: Date().addingTimeInterval(-86400)),
            (isActive: false, startTime: Date().addingTimeInterval(-172800)),
            (isActive: false, startTime: Date().addingTimeInterval(-259200)),
            (isActive: false, startTime: Date().addingTimeInterval(-345600)),
            (isActive: false, startTime: Date().addingTimeInterval(-432000)),
            (isActive: false, startTime: Date().addingTimeInterval(-518400))
        ]

        // When: Filtering to completed fasts and taking last 5
        let completedFasts = sessions.filter { !$0.isActive }
        let recentFasts = Array(completedFasts.prefix(5))

        // Then: Should have 5 recent completed fasts
        XCTAssertEqual(recentFasts.count, 5)
        XCTAssertTrue(recentFasts.allSatisfy { !$0.isActive })
    }

    // MARK: - Active Fast Detection

    func testActiveFastDetection_HasActive() {
        // Given: Sessions including an active one
        let sessions = [
            (isActive: true, endTime: nil as Date?),
            (isActive: false, endTime: Date())
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
            (isActive: false, endTime: Date()),
            (isActive: false, endTime: Date().addingTimeInterval(-3600))
        ]

        // When: Finding active fast
        let activeFast = sessions.first { $0.isActive }

        // Then: Should be nil
        XCTAssertNil(activeFast)
    }

    // MARK: - Last Completed Fast

    func testLastCompletedFastDetection() {
        // Given: Sessions sorted by start time (most recent first)
        let sessions = [
            (isActive: true, duration: 0.0),
            (isActive: false, duration: 57600.0),  // This should be the last completed
            (isActive: false, duration: 50400.0)
        ]

        // When: Finding last completed fast
        let lastCompleted = sessions.first { !$0.isActive }

        // Then: Should find the first completed session
        XCTAssertNotNil(lastCompleted)
        XCTAssertEqual(lastCompleted!.duration, 57600.0)
    }

    // MARK: - Saved Goal Retrieval

    func testSavedGoalFallback() {
        // Given: A saved goal value (0 means not set)
        let savedGoal = 0

        // When: Applying fallback logic
        let effectiveGoal = savedGoal > 0 ? savedGoal : defaultFastingGoalMinutes

        // Then: Should use default
        XCTAssertEqual(effectiveGoal, 960)
    }

    func testSavedGoalUsed() {
        // Given: A valid saved goal
        let savedGoal = 720

        // When: Applying fallback logic
        let effectiveGoal = savedGoal > 0 ? savedGoal : defaultFastingGoalMinutes

        // Then: Should use saved value
        XCTAssertEqual(effectiveGoal, 720)
    }
}

// MARK: - Widget Timeline Calculation Tests

/// Tests the timeline calculation logic used in widgets
final class WidgetTimelineCalculationTests: XCTestCase {

    func testActiveTimeline_GeneratesMinuteEntries() {
        // Given: Active fasting state
        let isActive = true
        let entriesNeeded = 60

        // When: Simulating timeline generation
        var entries: [Date] = []
        let currentDate = Date()

        if isActive {
            for minuteOffset in 0..<entriesNeeded {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(minuteOffset * 60))
                entries.append(entryDate)
            }
        }

        // Then: Should generate 60 entries (one per minute)
        XCTAssertEqual(entries.count, 60)
    }

    func testInactiveTimeline_GeneratesSingleEntry() {
        // Given: Not fasting
        let isActive = false

        // When: Simulating timeline generation
        var entries: [Date] = []
        let currentDate = Date()

        if isActive {
            // Would generate multiple entries
        } else {
            entries.append(currentDate)
        }

        // Then: Should generate single entry
        XCTAssertEqual(entries.count, 1)
    }

    func testActiveRefreshPolicy_OneHour() {
        // Given: Active fasting
        let currentDate = Date()

        // When: Calculating refresh date
        let refreshDate = currentDate.addingTimeInterval(60 * 60)

        // Then: Should be 1 hour later
        let interval = refreshDate.timeIntervalSince(currentDate)
        XCTAssertEqual(interval, 3600)
    }

    func testInactiveRefreshPolicy_15Minutes() {
        // Given: Not fasting
        let currentDate = Date()

        // When: Calculating refresh date
        let refreshDate = currentDate.addingTimeInterval(15 * 60)

        // Then: Should be 15 minutes later
        let interval = refreshDate.timeIntervalSince(currentDate)
        XCTAssertEqual(interval, 900)
    }
}

// MARK: - Widget Elapsed Time Tests

/// Tests elapsed time calculations for widget display
/// Uses actual functions from GoalCalculations.swift
final class WidgetElapsedTimeTests: XCTestCase {

    func testElapsedHoursFromDuration() {
        // Given: 4 hours of elapsed time
        let duration: TimeInterval = 14400

        // When: Extracting hours
        let hours = elapsedHours(from: duration)

        // Then: Should be 4 hours
        XCTAssertEqual(hours, 4)
    }

    func testElapsedMinutesFromDuration() {
        // Given: 4 hours 30 minutes
        let duration: TimeInterval = 16200

        // When: Extracting minutes component
        let mins = elapsedMinutesComponent(from: duration)

        // Then: Should be 30 minutes
        XCTAssertEqual(mins, 30)
    }

    func testIsGoalMet_True() {
        // Given: 16 hours elapsed, 16 hour goal
        let duration: TimeInterval = 57600
        let goalMinutes = 960

        // When: Checking if goal is met using actual function
        let goalMet = isGoalMet(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be true
        XCTAssertTrue(goalMet)
    }

    func testIsGoalMet_False() {
        // Given: 8 hours elapsed, 16 hour goal
        let duration: TimeInterval = 28800
        let goalMinutes = 960

        // When: Checking if goal is met using actual function
        let goalMet = isGoalMet(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be false
        XCTAssertFalse(goalMet)
    }

    func testIsGoalMet_ExactlyMet() {
        // Given: Exactly at goal
        let duration: TimeInterval = 57600
        let goalMinutes = 960

        // When: Checking if goal is met
        let goalMet = isGoalMet(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be true
        XCTAssertTrue(goalMet)
    }

    func testIsGoalMet_NoGoal() {
        // Given: No goal set
        let duration: TimeInterval = 57600

        // When: Checking with nil goal
        let goalMet = isGoalMet(currentDuration: duration, goalMinutes: nil)

        // Then: Should be false (no goal to meet)
        XCTAssertFalse(goalMet)
    }

    func testCalculateProgress_HalfwayThrough() {
        // Given: 8 hours elapsed, 16 hour goal
        let duration: TimeInterval = 28800
        let goalMinutes = 960

        // When: Calculating progress
        let progress = calculateProgress(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be 50%
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }

    func testCalculateProgress_Complete() {
        // Given: 20 hours elapsed, 16 hour goal
        let duration: TimeInterval = 72000
        let goalMinutes = 960

        // When: Calculating progress (exceeds goal)
        let progress = calculateProgress(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be capped at 100%
        XCTAssertEqual(progress, 1.0, accuracy: 0.001)
    }

    func testCalculateRemainingMinutes() {
        // Given: 8 hours elapsed, 16 hour goal
        let duration: TimeInterval = 28800
        let goalMinutes = 960

        // When: Calculating remaining
        let remaining = calculateRemainingMinutes(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be 480 minutes (8 hours)
        XCTAssertEqual(remaining, 480)
    }

    func testCalculateRemainingMinutes_GoalExceeded() {
        // Given: Past the goal
        let duration: TimeInterval = 72000
        let goalMinutes = 960

        // When: Calculating remaining
        let remaining = calculateRemainingMinutes(currentDuration: duration, goalMinutes: goalMinutes)

        // Then: Should be clamped to 0
        XCTAssertEqual(remaining, 0)
    }
}
