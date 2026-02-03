//
//  ViewCalculationTests.swift
//  LastFastTests
//
//  Tests for calculation logic used in views (GoalPickerView, FastingView, etc.)
//  These tests call the actual functions from GoalCalculations.swift
//

import XCTest
@testable import LastFast

// MARK: - GoalMode Tests

final class GoalModeTests: XCTestCase {

    func testGoalMode_AllCases() {
        // Given: All GoalMode cases
        let allCases = GoalMode.allCases

        // Then: Should have exactly 2 cases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.duration))
        XCTAssertTrue(allCases.contains(.endTime))
    }

    func testGoalMode_RawValues() {
        XCTAssertEqual(GoalMode.duration.rawValue, "Duration")
        XCTAssertEqual(GoalMode.endTime.rawValue, "End Time")
    }
}

// MARK: - Goal Picker Calculation Tests

/// Tests the calculation logic from GoalCalculations.swift used by GoalPickerView
final class GoalPickerCalculationTests: XCTestCase {

    // MARK: - isGoalValid Tests (actual function from GoalCalculations.swift)

    func testIsGoalValid_Duration_WithHoursOnly() {
        XCTAssertTrue(isGoalValid(mode: .duration, selectedHours: 8, selectedMinutes: 0, minutesUntilEndTime: 0))
    }

    func testIsGoalValid_Duration_WithMinutesOnly() {
        XCTAssertTrue(isGoalValid(mode: .duration, selectedHours: 0, selectedMinutes: 30, minutesUntilEndTime: 0))
    }

    func testIsGoalValid_Duration_WithBoth() {
        XCTAssertTrue(isGoalValid(mode: .duration, selectedHours: 8, selectedMinutes: 30, minutesUntilEndTime: 0))
    }

    func testIsGoalValid_Duration_WithZeros() {
        XCTAssertFalse(isGoalValid(mode: .duration, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: 0))
    }

    func testIsGoalValid_EndTime_InFuture() {
        XCTAssertTrue(isGoalValid(mode: .endTime, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: 60))
    }

    func testIsGoalValid_EndTime_InPast() {
        XCTAssertFalse(isGoalValid(mode: .endTime, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: 0))
    }

    func testIsGoalValid_EndTime_NegativeMinutes() {
        XCTAssertFalse(isGoalValid(mode: .endTime, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: -30))
    }

    // MARK: - calculateMinutesUntilEndTime Tests (actual function)

    func testCalculateMinutesUntilEndTime_FutureDate() {
        // Given: An end time 2 hours in the future
        let selectedEndTime = Date().addingTimeInterval(7200)

        // When: Calculating using actual function
        let result = calculateMinutesUntilEndTime(selectedEndTime)

        // Then: Should be approximately 120 minutes
        XCTAssertEqual(result, 120, accuracy: 1)
    }

    func testCalculateMinutesUntilEndTime_PastDate() {
        // Given: An end time in the past
        let selectedEndTime = Date().addingTimeInterval(-3600)

        // When: Calculating using actual function
        let result = calculateMinutesUntilEndTime(selectedEndTime)

        // Then: Should be 0 (clamped)
        XCTAssertEqual(result, 0)
    }

    func testCalculateMinutesUntilEndTime_Now() {
        // Given: End time is now
        let result = calculateMinutesUntilEndTime(Date())

        // Then: Should be 0 or close to it
        XCTAssertEqual(result, 0, accuracy: 1)
    }

    // MARK: - computeGoalMinutes Tests (actual function)

    func testComputeGoalMinutes_Duration_16Hours() {
        let result = computeGoalMinutes(mode: .duration, selectedHours: 16, selectedMinutes: 0, minutesUntilEndTime: 0)
        XCTAssertEqual(result, 960)
    }

    func testComputeGoalMinutes_Duration_8Hours30Minutes() {
        let result = computeGoalMinutes(mode: .duration, selectedHours: 8, selectedMinutes: 30, minutesUntilEndTime: 0)
        XCTAssertEqual(result, 510)
    }

    func testComputeGoalMinutes_EndTime() {
        let result = computeGoalMinutes(mode: .endTime, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: 480)
        XCTAssertEqual(result, 480)
    }

    func testComputeGoalMinutes_Duration_ZeroValues() {
        let result = computeGoalMinutes(mode: .duration, selectedHours: 0, selectedMinutes: 0, minutesUntilEndTime: 0)
        XCTAssertEqual(result, 0)
    }

    // MARK: - hoursFromMinutes Tests (actual function)

    func testHoursFromMinutes_ExactHours() {
        XCTAssertEqual(hoursFromMinutes(960), 16)
        XCTAssertEqual(hoursFromMinutes(480), 8)
        XCTAssertEqual(hoursFromMinutes(60), 1)
    }

    func testHoursFromMinutes_WithRemainder() {
        XCTAssertEqual(hoursFromMinutes(510), 8) // 8h 30m -> 8
        XCTAssertEqual(hoursFromMinutes(90), 1)  // 1h 30m -> 1
    }

    func testHoursFromMinutes_LessThanHour() {
        XCTAssertEqual(hoursFromMinutes(45), 0)
        XCTAssertEqual(hoursFromMinutes(0), 0)
    }

    // MARK: - minutesComponent Tests (actual function)

    func testMinutesComponent_ExactHours() {
        XCTAssertEqual(minutesComponent(960), 0)
        XCTAssertEqual(minutesComponent(60), 0)
    }

    func testMinutesComponent_WithRemainder() {
        XCTAssertEqual(minutesComponent(510), 30) // 8h 30m -> 30
        XCTAssertEqual(minutesComponent(90), 30)  // 1h 30m -> 30
        XCTAssertEqual(minutesComponent(75), 15)  // 1h 15m -> 15
    }

    func testMinutesComponent_LessThanHour() {
        XCTAssertEqual(minutesComponent(45), 45)
        XCTAssertEqual(minutesComponent(0), 0)
    }

    // MARK: - Mode Sync Tests

    func testModeSyncCalculation_DurationToEndTime() {
        // Given: Duration mode values of 8h 30m
        let selectedHours = 8
        let selectedMinutes = 30
        let currentGoal = computeGoalMinutes(mode: .duration, selectedHours: selectedHours, selectedMinutes: selectedMinutes, minutesUntilEndTime: 0)

        // Then: Should compute 510 minutes
        XCTAssertEqual(currentGoal, 510)
    }

    func testModeSyncCalculation_EndTimeToHoursMinutes() {
        // Given: 510 minutes until end time
        let minutesUntilEndTime = 510

        // When: Converting to hours and minutes
        let hours = hoursFromMinutes(minutesUntilEndTime)
        let minutes = minutesComponent(minutesUntilEndTime)

        // Then: Should be 8 hours 30 minutes
        XCTAssertEqual(hours, 8)
        XCTAssertEqual(minutes, 30)
    }
}

// MARK: - Fasting View Calculation Tests

/// Tests the calculation logic used in FastingView
/// Uses actual functions from GoalCalculations.swift
final class FastingViewCalculationTests: XCTestCase {

    // MARK: - currentDuration Calculation

    func testCurrentDuration_ActiveFast() {
        // Given: A fast started 3.5 hours ago
        let startTime = Date().addingTimeInterval(-3.5 * 3600)
        let currentTime = Date()

        // When: Calculating current duration
        let currentDuration = currentTime.timeIntervalSince(startTime)

        // Then: Should be approximately 3.5 hours in seconds
        XCTAssertEqual(currentDuration, 12600, accuracy: 1.0)
    }

    // MARK: - remainingMinutes Calculation (uses actual function)

    func testRemainingMinutes_HalfwayToGoal() {
        // Given: 8 hours elapsed, 16 hour goal
        let duration: TimeInterval = 8 * 3600
        let goal = 960 // 16 hours

        // When: Calculating remaining using actual function
        let remaining = calculateRemainingMinutes(currentDuration: duration, goalMinutes: goal)

        // Then: Should be 8 hours (480 minutes)
        XCTAssertEqual(remaining, 480)
    }

    func testRemainingMinutes_GoalExceeded() {
        // Given: 20 hours elapsed, 16 hour goal
        let duration: TimeInterval = 20 * 3600
        let goal = 960

        // When: Calculating remaining using actual function
        let remaining = calculateRemainingMinutes(currentDuration: duration, goalMinutes: goal)

        // Then: Should be 0 (clamped)
        XCTAssertEqual(remaining, 0)
    }

    func testRemainingMinutes_NoGoal() {
        // Given: No goal set
        let duration: TimeInterval = 8 * 3600

        // When: Calculating remaining using actual function
        let remaining = calculateRemainingMinutes(currentDuration: duration, goalMinutes: nil)

        // Then: Should be 0
        XCTAssertEqual(remaining, 0)
    }

    // MARK: - hours/minutes from remainingMinutes (uses actual functions)

    func testHoursFromRemainingMinutes() {
        let remaining = 510 // 8h 30m
        let hours = hoursFromMinutes(remaining)
        XCTAssertEqual(hours, 8)
    }

    func testMinutesFromRemainingMinutes() {
        let remaining = 510 // 8h 30m
        let minutes = minutesComponent(remaining)
        XCTAssertEqual(minutes, 30)
    }

    // MARK: - elapsedHours/elapsedMins Calculation (uses actual functions)

    func testElapsedHours() {
        let duration: TimeInterval = 12600 // 3.5 hours
        let hours = elapsedHours(from: duration)
        XCTAssertEqual(hours, 3)
    }

    func testElapsedMins() {
        let duration: TimeInterval = 12600 // 3.5 hours
        let mins = elapsedMinutesComponent(from: duration)
        XCTAssertEqual(mins, 30)
    }

    // MARK: - goalMet Calculation (uses actual function)

    func testGoalMet_BeforeGoal() {
        let duration: TimeInterval = 8 * 3600 // 8 hours
        XCTAssertFalse(isGoalMet(currentDuration: duration, goalMinutes: 960))
    }

    func testGoalMet_ExactlyAtGoal() {
        let duration: TimeInterval = 16 * 3600 // 16 hours
        XCTAssertTrue(isGoalMet(currentDuration: duration, goalMinutes: 960))
    }

    func testGoalMet_AfterGoal() {
        let duration: TimeInterval = 20 * 3600 // 20 hours
        XCTAssertTrue(isGoalMet(currentDuration: duration, goalMinutes: 960))
    }

    func testGoalMet_NoGoal() {
        let duration: TimeInterval = 100 * 3600
        XCTAssertFalse(isGoalMet(currentDuration: duration, goalMinutes: nil))
    }

    // MARK: - progress Calculation (uses actual function)

    func testProgress_AtZero() {
        XCTAssertEqual(calculateProgress(currentDuration: 0, goalMinutes: 960), 0, accuracy: 0.001)
    }

    func testProgress_AtHalfway() {
        let duration: TimeInterval = 8 * 3600 // 8 hours
        XCTAssertEqual(calculateProgress(currentDuration: duration, goalMinutes: 960), 0.5, accuracy: 0.001)
    }

    func testProgress_AtGoal() {
        let duration: TimeInterval = 16 * 3600 // 16 hours
        XCTAssertEqual(calculateProgress(currentDuration: duration, goalMinutes: 960), 1.0, accuracy: 0.001)
    }

    func testProgress_PastGoal_CappedAtOne() {
        let duration: TimeInterval = 24 * 3600 // 24 hours
        XCTAssertEqual(calculateProgress(currentDuration: duration, goalMinutes: 960), 1.0, accuracy: 0.001)
    }

    func testProgress_NoGoal() {
        XCTAssertEqual(calculateProgress(currentDuration: 10000, goalMinutes: nil), 0)
    }

    func testProgress_ZeroGoal() {
        XCTAssertEqual(calculateProgress(currentDuration: 10000, goalMinutes: 0), 0)
    }

    // MARK: - endTime Calculation

    func testEndTimeCalculation() {
        // Given: A start time and goal
        let startTime = Date()
        let goalMinutes = 960

        // When: Calculating end time
        let endTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))

        // Then: Should be 16 hours later
        let expectedEndTime = startTime.addingTimeInterval(57600)
        XCTAssertEqual(endTime, expectedEndTime)
    }

    func testEndTimeCalculation_NilGoal() {
        // Given: A start time with no goal
        let startTime = Date()
        let goalMinutes: Int? = nil

        // When: Calculating end time using optional map
        let endTime = goalMinutes.map { startTime.addingTimeInterval(TimeInterval($0 * 60)) }

        // Then: Should be nil
        XCTAssertNil(endTime)
    }
}

// MARK: - History Stats Calculation Tests

/// Tests the calculation logic used in HistoryStatsCard
final class HistoryStatsCalculationTests: XCTestCase {

    // MARK: - Test Helpers

    private func createTestSession(startedHoursAgo: Double, durationHours: Double, goalMet: Bool) -> FastingSession {
        let startTime = Date().addingTimeInterval(-startedHoursAgo * 3600)
        let session = FastingSession(startTime: startTime, goalMinutes: goalMet ? Int(durationHours * 60) : Int(durationHours * 60) + 60)
        session.endTime = startTime.addingTimeInterval(durationHours * 3600)
        return session
    }

    // MARK: - Total Fasts Count

    func testTotalFastsCount() {
        let sessions = [
            createTestSession(startedHoursAgo: 48, durationHours: 16, goalMet: true),
            createTestSession(startedHoursAgo: 72, durationHours: 14, goalMet: false),
            createTestSession(startedHoursAgo: 96, durationHours: 18, goalMet: true)
        ]

        XCTAssertEqual(sessions.count, 3)
    }

    // MARK: - Goals Met Count

    func testGoalsMetCount() {
        let sessions = [
            createTestSession(startedHoursAgo: 48, durationHours: 16, goalMet: true),
            createTestSession(startedHoursAgo: 72, durationHours: 14, goalMet: false),
            createTestSession(startedHoursAgo: 96, durationHours: 18, goalMet: true)
        ]

        let goalsMetCount = sessions.filter { $0.goalMet }.count
        XCTAssertEqual(goalsMetCount, 2)
    }

    func testGoalsMetCount_NoGoalsMet() {
        let sessions = [
            createTestSession(startedHoursAgo: 48, durationHours: 8, goalMet: false),
            createTestSession(startedHoursAgo: 72, durationHours: 10, goalMet: false)
        ]

        let goalsMetCount = sessions.filter { $0.goalMet }.count
        XCTAssertEqual(goalsMetCount, 0)
    }

    func testGoalsMetCount_AllGoalsMet() {
        let sessions = [
            createTestSession(startedHoursAgo: 48, durationHours: 16, goalMet: true),
            createTestSession(startedHoursAgo: 72, durationHours: 18, goalMet: true)
        ]

        let goalsMetCount = sessions.filter { $0.goalMet }.count
        XCTAssertEqual(goalsMetCount, 2)
    }

    // MARK: - Average Duration

    /// Replicates the averageDuration logic from HistoryStatsCard
    private func averageDuration(sessions: [FastingSession]) -> TimeInterval? {
        guard !sessions.isEmpty else { return nil }
        let total = sessions.reduce(0) { $0 + $1.duration }
        return total / Double(sessions.count)
    }

    func testAverageDuration_SingleSession() {
        let session = createTestSession(startedHoursAgo: 24, durationHours: 16, goalMet: true)
        let avg = averageDuration(sessions: [session])

        XCTAssertNotNil(avg)
        XCTAssertEqual(avg!, 16 * 3600, accuracy: 1.0)
    }

    func testAverageDuration_MultipleSessions() {
        let sessions = [
            createTestSession(startedHoursAgo: 48, durationHours: 16, goalMet: true),
            createTestSession(startedHoursAgo: 72, durationHours: 14, goalMet: false),
            createTestSession(startedHoursAgo: 96, durationHours: 18, goalMet: true)
        ]

        let avg = averageDuration(sessions: sessions)
        XCTAssertNotNil(avg)
        // Average of 16, 14, 18 = 48/3 = 16 hours
        XCTAssertEqual(avg!, 16 * 3600, accuracy: 1.0)
    }

    func testAverageDuration_EmptySessions() {
        let sessions: [FastingSession] = []
        let avg = averageDuration(sessions: sessions)

        XCTAssertNil(avg)
    }
}
