//
//  ChartCalculationTests.swift
//  LastFastTests
//
//  Tests for chart-related calculations (HistoryBarChart) and EditFastView validation
//

import XCTest
@testable import LastFast

// MARK: - Bar Chart Calculation Tests

final class BarChartCalculationTests: XCTestCase {

    // MARK: - maxDuration Calculation

    /// Replicates the maxDuration calculation from HistoryBarChart
    private func maxDuration(sessions: [FastingSession]) -> TimeInterval {
        let maxFasted = sessions.max(by: { $0.duration < $1.duration })?.duration ?? 3600
        let maxGoal = sessions.compactMap { $0.goalMinutes }.max().map { TimeInterval($0 * 60) } ?? 0
        return max(maxFasted, maxGoal)
    }

    func testMaxDuration_SingleSession_NoGoal() {
        // Given: A single session without goal
        let session = FastingSession(startTime: Date().addingTimeInterval(-57600)) // 16 hours
        session.endTime = Date()

        // When: Calculating maxDuration
        let max = maxDuration(sessions: [session])

        // Then: Should use the session duration
        XCTAssertEqual(max, 57600, accuracy: 10.0)
    }

    func testMaxDuration_SessionDurationHigherThanGoal() {
        // Given: Session duration exceeds goal
        let session = FastingSession(startTime: Date().addingTimeInterval(-72000), goalMinutes: 960) // 20h duration, 16h goal
        session.endTime = Date()

        // When: Calculating maxDuration
        let max = maxDuration(sessions: [session])

        // Then: Should use the higher duration
        XCTAssertEqual(max, 72000, accuracy: 10.0)
    }

    func testMaxDuration_GoalHigherThanSessionDuration() {
        // Given: Goal exceeds session duration
        let session = FastingSession(startTime: Date().addingTimeInterval(-28800), goalMinutes: 960) // 8h duration, 16h goal
        session.endTime = Date()

        // When: Calculating maxDuration
        let max = maxDuration(sessions: [session])

        // Then: Should use the goal (57600 seconds = 960 minutes)
        XCTAssertEqual(max, 57600, accuracy: 1.0)
    }

    func testMaxDuration_EmptySessions() {
        // Given: No sessions
        let sessions: [FastingSession] = []

        // When: Calculating maxDuration
        let max = maxDuration(sessions: sessions)

        // Then: Should default to 3600 (1 hour)
        XCTAssertEqual(max, 3600)
    }

    func testMaxDuration_MultipleSessions() {
        // Given: Multiple sessions with varying durations and goals
        let session1 = FastingSession(startTime: Date().addingTimeInterval(-57600), goalMinutes: 960) // 16h, 16h goal
        session1.endTime = Date()

        let session2 = FastingSession(startTime: Date().addingTimeInterval(-72000), goalMinutes: 1080) // 20h, 18h goal
        session2.endTime = Date()

        let session3 = FastingSession(startTime: Date().addingTimeInterval(-36000), goalMinutes: 720) // 10h, 12h goal
        session3.endTime = Date()

        // When: Calculating maxDuration
        let max = maxDuration(sessions: [session1, session2, session3])

        // Then: Should use the highest value (20h = 72000 seconds)
        XCTAssertEqual(max, 72000, accuracy: 10.0)
    }

    // MARK: - Bar Height Calculation

    /// Replicates the bar height calculation from HistoryBarChart
    private func barHeight(sessionDuration: TimeInterval, maxDuration: TimeInterval, barAreaHeight: CGFloat) -> CGFloat {
        maxDuration > 0 ? max(4, CGFloat(sessionDuration / maxDuration) * barAreaHeight) : 4
    }

    func testBarHeight_FullHeight() {
        // Given: Session duration equals maxDuration
        let result = barHeight(sessionDuration: 57600, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be full height
        XCTAssertEqual(result, 160, accuracy: 0.1)
    }

    func testBarHeight_HalfHeight() {
        // Given: Session duration is half of maxDuration
        let result = barHeight(sessionDuration: 28800, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be half height
        XCTAssertEqual(result, 80, accuracy: 0.1)
    }

    func testBarHeight_MinimumHeight() {
        // Given: Very short session
        let result = barHeight(sessionDuration: 60, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be at least 4 (minimum)
        XCTAssertGreaterThanOrEqual(result, 4)
    }

    func testBarHeight_ZeroMaxDuration() {
        // Given: Zero maxDuration (edge case)
        let result = barHeight(sessionDuration: 1000, maxDuration: 0, barAreaHeight: 160)

        // Then: Should be minimum (4)
        XCTAssertEqual(result, 4)
    }

    // MARK: - Goal Height Calculation

    /// Replicates the goal height calculation from HistoryBarChart
    private func goalHeight(goalMinutes: Int?, maxDuration: TimeInterval, barAreaHeight: CGFloat) -> CGFloat? {
        guard let goalMinutes = goalMinutes, maxDuration > 0 else { return nil }
        return CGFloat(TimeInterval(goalMinutes * 60) / maxDuration) * barAreaHeight
    }

    func testGoalHeight_AtMaxDuration() {
        // Given: Goal equals maxDuration
        let result = goalHeight(goalMinutes: 960, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be full height
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 160, accuracy: 0.1)
    }

    func testGoalHeight_HalfOfMaxDuration() {
        // Given: Goal is half of maxDuration
        let result = goalHeight(goalMinutes: 480, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be half height
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 80, accuracy: 0.1)
    }

    func testGoalHeight_NoGoal() {
        // Given: No goal set
        let result = goalHeight(goalMinutes: nil, maxDuration: 57600, barAreaHeight: 160)

        // Then: Should be nil
        XCTAssertNil(result)
    }

    func testGoalHeight_ZeroMaxDuration() {
        // Given: Zero maxDuration
        let result = goalHeight(goalMinutes: 960, maxDuration: 0, barAreaHeight: 160)

        // Then: Should be nil
        XCTAssertNil(result)
    }

    // MARK: - formatShortDuration Tests

    /// Replicates the formatShortDuration function from HistoryBarChart
    private func formatShortDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h\(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    func testFormatShortDuration_HoursAndMinutes() {
        let result = formatShortDuration(59400) // 16h 30m
        XCTAssertEqual(result, "16h30m")
    }

    func testFormatShortDuration_HoursOnly() {
        let result = formatShortDuration(57600) // 16h 0m
        XCTAssertEqual(result, "16h0m")
    }

    func testFormatShortDuration_MinutesOnly() {
        let result = formatShortDuration(2700) // 45m
        XCTAssertEqual(result, "45m")
    }

    func testFormatShortDuration_Zero() {
        let result = formatShortDuration(0)
        XCTAssertEqual(result, "0m")
    }

    // MARK: - formatChartDate Tests

    func testFormatChartDate() {
        // Given: A specific date
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 15
        let date = Calendar.current.date(from: components)!

        // When: Formatting with the chart date format
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        let result = formatter.string(from: date)

        // Then: Should be in dd/MM format
        XCTAssertEqual(result, "15/03")
    }

    // MARK: - Goal Line Point Calculation

    func testGoalLinePointCalculation() {
        // Given: Chart parameters
        let barWidth: CGFloat = 56
        let barSpacing: CGFloat = 8
        let barAreaHeight: CGFloat = 160
        let maxDuration: TimeInterval = 57600
        let goalMinutes = 960

        // When: Calculating point for index 0
        let index = 0
        let x = CGFloat(index) * (barWidth + barSpacing) + barWidth / 2
        let goalHeight = CGFloat(TimeInterval(goalMinutes * 60) / maxDuration) * barAreaHeight
        let y = barAreaHeight - goalHeight

        // Then: X should be center of first bar, Y should be at top (goal = max)
        XCTAssertEqual(x, 28, accuracy: 0.1) // barWidth/2
        XCTAssertEqual(y, 0, accuracy: 0.1) // Full height goal
    }

    func testGoalLinePointCalculation_SecondBar() {
        // Given: Chart parameters for second bar
        let barWidth: CGFloat = 56
        let barSpacing: CGFloat = 8
        let index = 1

        // When: Calculating x position
        let x = CGFloat(index) * (barWidth + barSpacing) + barWidth / 2

        // Then: X should be center of second bar
        XCTAssertEqual(x, 92, accuracy: 0.1) // 64 + 28
    }
}

// MARK: - Edit Fast Validation Tests

final class EditFastValidationTests: XCTestCase {

    // MARK: - isValid Calculation

    /// Replicates the isValid logic from EditFastView
    private func isValid(startTime: Date, endTime: Date, goalTotalMinutes: Int) -> Bool {
        endTime > startTime && goalTotalMinutes > 0
    }

    func testIsValid_ValidEdit() {
        let startTime = Date().addingTimeInterval(-3600)
        let endTime = Date()

        XCTAssertTrue(isValid(startTime: startTime, endTime: endTime, goalTotalMinutes: 960))
    }

    func testIsValid_EndTimeBeforeStartTime() {
        let startTime = Date()
        let endTime = Date().addingTimeInterval(-3600)

        XCTAssertFalse(isValid(startTime: startTime, endTime: endTime, goalTotalMinutes: 960))
    }

    func testIsValid_EndTimeEqualsStartTime() {
        let time = Date()

        XCTAssertFalse(isValid(startTime: time, endTime: time, goalTotalMinutes: 960))
    }

    func testIsValid_ZeroGoal() {
        let startTime = Date().addingTimeInterval(-3600)
        let endTime = Date()

        XCTAssertFalse(isValid(startTime: startTime, endTime: endTime, goalTotalMinutes: 0))
    }

    func testIsValid_NegativeGoal() {
        let startTime = Date().addingTimeInterval(-3600)
        let endTime = Date()

        XCTAssertFalse(isValid(startTime: startTime, endTime: endTime, goalTotalMinutes: -10))
    }

    // MARK: - goalTotalMinutes Calculation

    func testGoalTotalMinutes_HoursAndMinutes() {
        let goalHours = 16
        let goalMinutes = 30
        let total = goalHours * 60 + goalMinutes
        XCTAssertEqual(total, 990)
    }

    func testGoalTotalMinutes_HoursOnly() {
        let goalHours = 16
        let goalMinutes = 0
        let total = goalHours * 60 + goalMinutes
        XCTAssertEqual(total, 960)
    }

    func testGoalTotalMinutes_MinutesOnly() {
        let goalHours = 0
        let goalMinutes = 45
        let total = goalHours * 60 + goalMinutes
        XCTAssertEqual(total, 45)
    }

    // MARK: - Duration Calculation

    func testDurationCalculation() {
        let startTime = Date().addingTimeInterval(-57600)
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        XCTAssertEqual(duration, 57600, accuracy: 1.0)
    }

    // MARK: - Goal Met in Edit View

    func testGoalMetCalculation_GoalMet() {
        let duration: TimeInterval = 57600 // 16 hours
        let goalTotalMinutes = 960 // 16 hours
        let goalMet = Int(duration) / 60 >= goalTotalMinutes
        XCTAssertTrue(goalMet)
    }

    func testGoalMetCalculation_GoalNotMet() {
        let duration: TimeInterval = 28800 // 8 hours
        let goalTotalMinutes = 960 // 16 hours
        let goalMet = Int(duration) / 60 >= goalTotalMinutes
        XCTAssertFalse(goalMet)
    }

    func testGoalMetCalculation_ExactlyAtGoal() {
        let duration: TimeInterval = 57600 // 16 hours exactly
        let goalTotalMinutes = 960 // 16 hours
        let goalMet = Int(duration) / 60 >= goalTotalMinutes
        XCTAssertTrue(goalMet)
    }
}

// MARK: - Item Model Tests

final class ItemTests: XCTestCase {

    func testItemInitialization() {
        // Given: A timestamp
        let timestamp = Date()

        // When: Creating an Item
        let item = Item(timestamp: timestamp)

        // Then: Timestamp should be set
        XCTAssertEqual(item.timestamp, timestamp)
    }

    func testItemTimestampUpdate() {
        // Given: An item with initial timestamp
        let initialTimestamp = Date().addingTimeInterval(-3600)
        let item = Item(timestamp: initialTimestamp)

        // When: Updating timestamp
        let newTimestamp = Date()
        item.timestamp = newTimestamp

        // Then: Timestamp should be updated
        XCTAssertEqual(item.timestamp, newTimestamp)
        XCTAssertNotEqual(item.timestamp, initialTimestamp)
    }
}
