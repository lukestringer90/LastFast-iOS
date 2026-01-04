//
//  LastFastTests.swift
//  LastFastTests
//
//  Created by Luke Stringer on 31/12/2025.
//

import XCTest
import SwiftData
@testable import LastFast

// MARK: - Mock Dependencies

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

// MARK: - FastingSession Tests

final class FastingSessionTests: XCTestCase {
    
    var session: FastingSession!
    
    override func setUp() {
        super.setUp()
        MockDateProvider.reset()
    }
    
    override func tearDown() {
        session = nil
        MockDateProvider.reset()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization_WithDefaultValues_CreatesActiveSession() {
        // Given: No parameters provided
        
        // When: Creating a new session
        session = FastingSession()
        
        // Then: Session should be active with no goal
        XCTAssertNotNil(session.id)
        XCTAssertNotNil(session.startTime)
        XCTAssertNil(session.endTime)
        XCTAssertNil(session.goalMinutes)
        XCTAssertTrue(session.isActive)
    }
    
    func testInitialization_WithCustomStartTime_SetsStartTimeCorrectly() {
        // Given: A specific start time
        let customStartTime = Date().addingTimeInterval(-3600) // 1 hour ago
        
        // When: Creating a session with custom start time
        session = FastingSession(startTime: customStartTime)
        
        // Then: Start time should match
        XCTAssertEqual(session.startTime, customStartTime)
        XCTAssertTrue(session.isActive)
    }
    
    func testInitialization_WithGoalMinutes_SetsGoalCorrectly() {
        // Given: A goal of 16 hours (960 minutes)
        let goalMinutes = 960
        
        // When: Creating a session with goal
        session = FastingSession(goalMinutes: goalMinutes)
        
        // Then: Goal should be set
        XCTAssertEqual(session.goalMinutes, goalMinutes)
    }
    
    // MARK: - isActive Tests
    
    func testIsActive_WhenEndTimeIsNil_ReturnsTrue() {
        // Given: A session without end time
        session = FastingSession()
        
        // When: Checking isActive
        let isActive = session.isActive
        
        // Then: Should be active
        XCTAssertTrue(isActive)
    }
    
    func testIsActive_WhenEndTimeIsSet_ReturnsFalse() {
        // Given: A session that has been stopped
        session = FastingSession()
        session.stop()
        
        // When: Checking isActive
        let isActive = session.isActive
        
        // Then: Should not be active
        XCTAssertFalse(isActive)
    }
    
    // MARK: - Duration Tests
    
    func testDuration_ForActiveSession_ReturnsElapsedTime() {
        // Given: A session started 2 hours ago
        let startTime = Date().addingTimeInterval(-7200) // 2 hours ago
        session = FastingSession(startTime: startTime)
        
        // When: Getting duration
        let duration = session.duration
        
        // Then: Duration should be approximately 2 hours (allow 1 second tolerance)
        XCTAssertEqual(duration, 7200, accuracy: 1.0)
    }
    
    func testDuration_ForCompletedSession_ReturnsFixedDuration() {
        // Given: A session started 3 hours ago and stopped 1 hour ago
        let startTime = Date().addingTimeInterval(-10800) // 3 hours ago
        let endTime = Date().addingTimeInterval(-3600) // 1 hour ago
        session = FastingSession(startTime: startTime)
        session.endTime = endTime
        
        // When: Getting duration
        let duration = session.duration
        
        // Then: Duration should be 2 hours
        XCTAssertEqual(duration, 7200, accuracy: 1.0)
    }
    
    func testDuration_JustStarted_ReturnsNearZero() {
        // Given: A session just started
        session = FastingSession(startTime: Date())
        
        // When: Getting duration immediately
        let duration = session.duration
        
        // Then: Duration should be near zero
        XCTAssertLessThan(duration, 1.0)
    }
    
    // MARK: - Goal Met Tests
    
    func testGoalMet_WhenNoGoalSet_ReturnsFalse() {
        // Given: A session without goal that has been running for 24 hours
        let startTime = Date().addingTimeInterval(-86400)
        session = FastingSession(startTime: startTime, goalMinutes: nil)
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Should return false (no goal to meet)
        XCTAssertFalse(goalMet)
    }
    
    func testGoalMet_WhenDurationLessThanGoal_ReturnsFalse() {
        // Given: A 16-hour goal with 8 hours elapsed
        let startTime = Date().addingTimeInterval(-28800) // 8 hours ago
        session = FastingSession(startTime: startTime, goalMinutes: 960) // 16 hour goal
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should not be met
        XCTAssertFalse(goalMet)
    }
    
    func testGoalMet_WhenDurationEqualsGoal_ReturnsTrue() {
        // Given: A 16-hour goal with exactly 16 hours elapsed
        let startTime = Date().addingTimeInterval(-57600) // 16 hours ago
        session = FastingSession(startTime: startTime, goalMinutes: 960) // 16 hour goal
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should be met
        XCTAssertTrue(goalMet)
    }
    
    func testGoalMet_WhenDurationExceedsGoal_ReturnsTrue() {
        // Given: A 16-hour goal with 20 hours elapsed
        let startTime = Date().addingTimeInterval(-72000) // 20 hours ago
        session = FastingSession(startTime: startTime, goalMinutes: 960) // 16 hour goal
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should be met
        XCTAssertTrue(goalMet)
    }
    
    func testGoalMet_WithOneMinuteGoal_MetsAfterOneMinute() {
        // Given: A 1-minute goal with 61 seconds elapsed
        let startTime = Date().addingTimeInterval(-61)
        session = FastingSession(startTime: startTime, goalMinutes: 1)
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should be met
        XCTAssertTrue(goalMet)
    }
    
    func testGoalMet_WithOneMinuteGoal_NotMetAfter59Seconds() {
        // Given: A 1-minute goal with 59 seconds elapsed
        let startTime = Date().addingTimeInterval(-59)
        session = FastingSession(startTime: startTime, goalMinutes: 1)
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should not be met
        XCTAssertFalse(goalMet)
    }
    
    // MARK: - Stop Tests
    
    func testStop_SetsEndTime() {
        // Given: An active session
        session = FastingSession()
        XCTAssertNil(session.endTime)
        
        // When: Stopping the session
        session.stop()
        
        // Then: End time should be set
        XCTAssertNotNil(session.endTime)
    }
    
    func testStop_MakesSessionInactive() {
        // Given: An active session
        session = FastingSession()
        XCTAssertTrue(session.isActive)
        
        // When: Stopping the session
        session.stop()
        
        // Then: Session should no longer be active
        XCTAssertFalse(session.isActive)
    }
    
    func testStop_FreezesDuration() {
        // Given: A session started 1 hour ago
        let startTime = Date().addingTimeInterval(-3600)
        session = FastingSession(startTime: startTime)
        
        // When: Stopping the session
        session.stop()
        let durationAtStop = session.duration
        
        // Then: Duration should be fixed (approximately 1 hour)
        XCTAssertEqual(durationAtStop, 3600, accuracy: 1.0)
        
        // And: Duration should remain the same after waiting
        // (simulated by checking endTime is used)
        XCTAssertNotNil(session.endTime)
    }
    
    // MARK: - Formatted Duration Tests
    
    func testFormattedDuration_UnderOneMinute_ShowsSecondsOnly() {
        // Given: A session with 45 seconds elapsed
        let startTime = Date().addingTimeInterval(-45)
        session = FastingSession(startTime: startTime)
        
        // When: Getting formatted duration
        let formatted = session.formattedDuration
        
        // Then: Should show seconds only
        XCTAssertTrue(formatted.contains("s"))
        XCTAssertFalse(formatted.contains("m"))
        XCTAssertFalse(formatted.contains("h"))
    }
    
    func testFormattedDuration_UnderOneHour_ShowsMinutesAndSeconds() {
        // Given: A session with 5 minutes 30 seconds elapsed
        let startTime = Date().addingTimeInterval(-330)
        session = FastingSession(startTime: startTime)
        
        // When: Getting formatted duration
        let formatted = session.formattedDuration
        
        // Then: Should show minutes and seconds
        XCTAssertTrue(formatted.contains("m"))
        XCTAssertTrue(formatted.contains("s"))
        XCTAssertFalse(formatted.contains("h"))
    }
    
    func testFormattedDuration_OverOneHour_ShowsHoursMinutesSeconds() {
        // Given: A session with 2 hours 15 minutes 30 seconds elapsed
        let twoHours: TimeInterval = 2 * 3600
        let fifteenMinutes: TimeInterval = 15 * 60
        let thirtySeconds: TimeInterval = 30
        let elapsed = twoHours + fifteenMinutes + thirtySeconds
        let startTime = Date().addingTimeInterval(-elapsed)
        session = FastingSession(startTime: startTime)
        
        // When: Getting formatted duration
        let formatted = session.formattedDuration
        
        // Then: Should show hours, minutes, and seconds
        XCTAssertTrue(formatted.contains("h"))
        XCTAssertTrue(formatted.contains("m"))
        XCTAssertTrue(formatted.contains("s"))
    }
    
    func testFormattedDurationShort_UnderOneHour_ShowsZeroHours() {
        // Given: A session with 45 minutes elapsed
        let startTime = Date().addingTimeInterval(-2700) // 45 minutes
        session = FastingSession(startTime: startTime)
        
        // When: Getting short formatted duration
        let formatted = session.formattedDurationShort
        
        // Then: Should show "0:45" format
        XCTAssertEqual(formatted, "0:45")
    }
    
    func testFormattedDurationShort_OverOneHour_ShowsHoursAndMinutes() {
        // Given: A session with 2 hours 5 minutes elapsed
        let twoHours: TimeInterval = 2 * 3600
        let fiveMinutes: TimeInterval = 5 * 60
        let startTime = Date().addingTimeInterval(-(twoHours + fiveMinutes))
        session = FastingSession(startTime: startTime)
        
        // When: Getting short formatted duration
        let formatted = session.formattedDurationShort
        
        // Then: Should show "2:05" format
        XCTAssertEqual(formatted, "2:05")
    }
    
    // MARK: - Edge Cases
    
    func testSession_WithZeroGoal_GoalMetImmediately() {
        // Given: A session with 0 minute goal
        session = FastingSession(goalMinutes: 0)
        
        // When: Checking goalMet immediately
        let goalMet = session.goalMet
        
        // Then: Goal should be met (0 >= 0)
        XCTAssertTrue(goalMet)
    }
    
    func testSession_WithVeryLongDuration_HandlesCorrectly() {
        // Given: A session started 30 days ago
        let startTime = Date().addingTimeInterval(-30 * 24 * 3600)
        session = FastingSession(startTime: startTime, goalMinutes: 720)
        
        // When: Getting duration and checking goal
        let duration = session.duration
        let goalMet = session.goalMet
        
        // Then: Should handle large duration correctly
        XCTAssertGreaterThan(duration, 0)
        XCTAssertTrue(goalMet)
    }
    
    func testSession_WithFutureStartTime_HandlesGracefully() {
        // Given: A session with start time in the future (edge case)
        let futureStart = Date().addingTimeInterval(3600) // 1 hour in future
        session = FastingSession(startTime: futureStart, goalMinutes: 60)
        
        // When: Getting duration
        let duration = session.duration
        
        // Then: Duration should be negative (or handled appropriately)
        XCTAssertLessThan(duration, 0)
    }
}

// MARK: - Time Formatting Tests

final class TimeFormattingTests: XCTestCase {
    
    func testFormat24HourTime_MorningTime_FormatsCorrectly() {
        // Given: A morning time (9:30 AM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 9
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "09:30"
        XCTAssertEqual(formatted, "09:30")
    }
    
    func testFormat24HourTime_AfternoonTime_FormatsCorrectly() {
        // Given: An afternoon time (2:45 PM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 45
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "14:45"
        XCTAssertEqual(formatted, "14:45")
    }
    
    func testFormat24HourTime_Midnight_FormatsCorrectly() {
        // Given: Midnight
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "00:00"
        XCTAssertEqual(formatted, "00:00")
    }
    
    func testFormat24HourTime_Noon_FormatsCorrectly() {
        // Given: Noon
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 12
        components.minute = 0
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "12:00"
        XCTAssertEqual(formatted, "12:00")
    }
    
    func testFormat24HourTime_SingleDigitMinutes_PadsWithZero() {
        // Given: A time with single digit minutes (3:05 PM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 15
        components.minute = 5
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "15:05" (padded)
        XCTAssertEqual(formatted, "15:05")
    }
    
    func testFormat24HourTime_EndOfDay_FormatsCorrectly() {
        // Given: 11:59 PM
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 23
        components.minute = 59
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "23:59"
        XCTAssertEqual(formatted, "23:59")
    }
}

// MARK: - Constants Tests

final class ConstantsTests: XCTestCase {
    
    func testDefaultFastingGoalMinutes_Is12Hours() {
        // Given: The default constant
        
        // When: Checking its value
        let defaultGoal = defaultFastingGoalMinutes
        
        // Then: Should be 720 minutes (12 hours)
        XCTAssertEqual(defaultGoal, 720)
    }
    
    func testFastingGoalStorageKey_HasCorrectValue() {
        // Given: The storage key constant
        
        // When: Checking its value
        let key = fastingGoalStorageKey
        
        // Then: Should match expected key
        XCTAssertEqual(key, "fastingGoalMinutes")
    }
}

// MARK: - Live Activity Attributes Tests

#if canImport(ActivityKit)
final class LiveActivityAttributesTests: XCTestCase {
    
    func testLastFastWidgetAttributes_StoresStaticData() {
        // Given: Static attributes for live activity
        let startTime = Date()
        let goalMinutes = 960
        
        // When: Creating attributes
        let attributes = LastFastWidgetAttributes(
            startTime: startTime,
            goalMinutes: goalMinutes
        )
        
        // Then: Should store data correctly
        XCTAssertEqual(attributes.startTime, startTime)
        XCTAssertEqual(attributes.goalMinutes, goalMinutes)
    }
    
    func testContentState_InitialState_IsNotGoalMet() {
        // Given: Initial content state
        
        // When: Creating initial state
        let state = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: 0,
            goalMet: false
        )
        
        // Then: Should be initial state
        XCTAssertEqual(state.elapsedSeconds, 0)
        XCTAssertFalse(state.goalMet)
    }
    
    func testContentState_GoalMetState_IsTrue() {
        // Given: Goal met content state
        let elapsedSeconds = 57600 // 16 hours
        
        // When: Creating goal met state
        let state = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: elapsedSeconds,
            goalMet: true
        )
        
        // Then: Should reflect goal met
        XCTAssertEqual(state.elapsedSeconds, elapsedSeconds)
        XCTAssertTrue(state.goalMet)
    }
    
    func testContentState_IsHashable() {
        // Given: Two identical states
        let state1 = LastFastWidgetAttributes.ContentState(elapsedSeconds: 100, goalMet: false)
        let state2 = LastFastWidgetAttributes.ContentState(elapsedSeconds: 100, goalMet: false)
        
        // When: Comparing hashes
        let hash1 = state1.hashValue
        let hash2 = state2.hashValue
        
        // Then: Should be equal
        XCTAssertEqual(hash1, hash2)
    }
    
    func testContentState_IsCodable() throws {
        // Given: A content state
        let originalState = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: 3600,
            goalMet: true
        )
        
        // When: Encoding and decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalState)
        
        let decoder = JSONDecoder()
        let decodedState = try decoder.decode(LastFastWidgetAttributes.ContentState.self, from: data)
        
        // Then: Should be equal
        XCTAssertEqual(decodedState.elapsedSeconds, originalState.elapsedSeconds)
        XCTAssertEqual(decodedState.goalMet, originalState.goalMet)
    }
}
#endif

// MARK: - Goal Calculation Tests

final class GoalCalculationTests: XCTestCase {
    
    func testRemainingMinutes_WhenHalfwayToGoal() {
        // Given: A 16-hour goal with 8 hours elapsed
        let goalMinutes = 960 // 16 hours
        let elapsedSeconds = 8 * 3600 // 8 hours
        
        // When: Calculating remaining minutes
        let elapsedMinutes = elapsedSeconds / 60
        let remainingMinutes = max(0, goalMinutes - elapsedMinutes)
        
        // Then: Should have 8 hours remaining
        XCTAssertEqual(remainingMinutes, 480)
    }
    
    func testRemainingMinutes_WhenGoalExceeded_ReturnsZero() {
        // Given: A 16-hour goal with 20 hours elapsed
        let goalMinutes = 960 // 16 hours
        let elapsedSeconds = 20 * 3600 // 20 hours
        
        // When: Calculating remaining minutes
        let elapsedMinutes = elapsedSeconds / 60
        let remainingMinutes = max(0, goalMinutes - elapsedMinutes)
        
        // Then: Should be zero (not negative)
        XCTAssertEqual(remainingMinutes, 0)
    }
    
    func testProgress_WhenHalfwayToGoal_ReturnsFiftyPercent() {
        // Given: A 16-hour goal with 8 hours elapsed
        let goalMinutes = 960.0
        let elapsedMinutes = 480.0
        
        // When: Calculating progress
        let progress = min(1.0, elapsedMinutes / goalMinutes)
        
        // Then: Should be 50%
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }
    
    func testProgress_WhenGoalMet_ReturnsOne() {
        // Given: A 16-hour goal with 16 hours elapsed
        let goalMinutes = 960.0
        let elapsedMinutes = 960.0
        
        // When: Calculating progress
        let progress = min(1.0, elapsedMinutes / goalMinutes)
        
        // Then: Should be 100%
        XCTAssertEqual(progress, 1.0)
    }
    
    func testProgress_WhenGoalExceeded_CapsAtOne() {
        // Given: A 16-hour goal with 20 hours elapsed
        let goalMinutes = 960.0
        let elapsedMinutes = 1200.0
        
        // When: Calculating progress
        let progress = min(1.0, elapsedMinutes / goalMinutes)
        
        // Then: Should cap at 100%
        XCTAssertEqual(progress, 1.0)
    }
    
    func testProgress_WithZeroGoal_HandlesGracefully() {
        // Given: A zero goal (edge case)
        let goalMinutes = 0.0
        let elapsedMinutes = 100.0
        
        // When: Calculating progress (with safety check)
        let progress: Double
        if goalMinutes > 0 {
            progress = min(1.0, elapsedMinutes / goalMinutes)
        } else {
            progress = 0
        }
        
        // Then: Should handle zero goal
        XCTAssertEqual(progress, 0)
    }
    
    func testEndTimeCalculation_From16HourGoal() {
        // Given: A start time and 16-hour goal
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 20
        components.minute = 0
        let startTime = Calendar.current.date(from: components)!
        let goalMinutes = 960
        
        // When: Calculating end time
        let endTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        
        // Then: End time should be next day at 12:00
        let endComponents = Calendar.current.dateComponents([.day, .hour, .minute], from: endTime)
        XCTAssertEqual(endComponents.day, 16)
        XCTAssertEqual(endComponents.hour, 12)
        XCTAssertEqual(endComponents.minute, 0)
    }
}

// MARK: - Duration Display Tests

final class DurationDisplayTests: XCTestCase {
    
    func testElapsedHours_CalculatesCorrectly() {
        // Given: Various durations in seconds
        let testCases: [(seconds: Int, expectedHours: Int)] = [
            (0, 0),
            (3599, 0),      // Just under 1 hour
            (3600, 1),      // Exactly 1 hour
            (7200, 2),      // 2 hours
            (36000, 10),    // 10 hours
            (86400, 24),    // 24 hours
        ]
        
        for testCase in testCases {
            // When: Calculating elapsed hours
            let elapsedHours = testCase.seconds / 3600
            
            // Then: Should match expected
            XCTAssertEqual(elapsedHours, testCase.expectedHours, "Failed for \(testCase.seconds) seconds")
        }
    }
    
    func testElapsedMinutes_CalculatesCorrectly() {
        // Given: Various durations in seconds
        let testCases: [(seconds: Int, expectedMinutes: Int)] = [
            (0, 0),
            (59, 0),        // Just under 1 minute
            (60, 1),        // Exactly 1 minute
            (3599, 59),     // 59 minutes
            (3660, 1),      // 1 hour 1 minute -> 1 minute remainder
            (7380, 3),      // 2 hours 3 minutes -> 3 minutes remainder
        ]
        
        for testCase in testCases {
            // When: Calculating elapsed minutes (remainder after hours)
            let elapsedMins = (testCase.seconds % 3600) / 60
            
            // Then: Should match expected
            XCTAssertEqual(elapsedMins, testCase.expectedMinutes, "Failed for \(testCase.seconds) seconds")
        }
    }
    
    func testRemainingHoursAndMinutes_FromRemainingMinutes() {
        // Given: Remaining minutes values
        let testCases: [(remainingMinutes: Int, expectedHours: Int, expectedMins: Int)] = [
            (0, 0, 0),
            (30, 0, 30),
            (60, 1, 0),
            (90, 1, 30),
            (480, 8, 0),    // 8 hours
            (495, 8, 15),   // 8 hours 15 minutes
        ]
        
        for testCase in testCases {
            // When: Calculating hours and minutes
            let hours = testCase.remainingMinutes / 60
            let minutes = testCase.remainingMinutes % 60
            
            // Then: Should match expected
            XCTAssertEqual(hours, testCase.expectedHours, "Hours failed for \(testCase.remainingMinutes)")
            XCTAssertEqual(minutes, testCase.expectedMins, "Minutes failed for \(testCase.remainingMinutes)")
        }
    }
}

// MARK: - Feature Flag Tests

final class FeatureFlagTests: XCTestCase {
    
    func testLiveActivityEnabled_HasExpectedDefaultValue() {
        // Given: The live activity feature flag
        
        // When: Checking its value
        let isEnabled = liveActivityEnabled
        
        // Then: Should be false by default (as per current implementation)
        XCTAssertFalse(isEnabled)
    }
}

// MARK: - Mock UserDefaults Tests

final class MockUserDefaultsTests: XCTestCase {
    
    var mockDefaults: MockUserDefaults!
    
    override func setUp() {
        super.setUp()
        mockDefaults = MockUserDefaults()
    }
    
    override func tearDown() {
        mockDefaults = nil
        super.tearDown()
    }
    
    func testMockUserDefaults_SetAndGet_WorksCorrectly() {
        // Given: A mock UserDefaults
        
        // When: Setting values
        mockDefaults.set(720, forKey: "fastingGoalMinutes")
        mockDefaults.set(true, forKey: "isFasting")
        mockDefaults.set(1234567890.0, forKey: "startTime")
        
        // Then: Should retrieve correctly
        XCTAssertEqual(mockDefaults.integer(forKey: "fastingGoalMinutes"), 720)
        XCTAssertTrue(mockDefaults.bool(forKey: "isFasting"))
        XCTAssertEqual(mockDefaults.double(forKey: "startTime"), 1234567890.0)
    }
    
    func testMockUserDefaults_Reset_ClearsAllValues() {
        // Given: A mock with values
        mockDefaults.set(720, forKey: "goal")
        mockDefaults.set(true, forKey: "active")
        
        // When: Resetting
        mockDefaults.reset()
        
        // Then: Values should be cleared
        XCTAssertEqual(mockDefaults.integer(forKey: "goal"), 0)
        XCTAssertFalse(mockDefaults.bool(forKey: "active"))
    }
    
    func testMockUserDefaults_RemoveObject_RemovesSpecificKey() {
        // Given: A mock with multiple values
        mockDefaults.set(720, forKey: "goal")
        mockDefaults.set(true, forKey: "active")
        
        // When: Removing one key
        mockDefaults.removeObject(forKey: "goal")
        
        // Then: Only that key should be removed
        XCTAssertNil(mockDefaults.object(forKey: "goal"))
        XCTAssertTrue(mockDefaults.bool(forKey: "active"))
    }
}

// MARK: - Integration-Style Tests

final class FastingWorkflowTests: XCTestCase {
    
    func testCompleteHappyPath_StartFastMeetGoalStop() {
        // Given: A new fasting session with 1-minute goal for testing
        let startTime = Date()
        let session = FastingSession(startTime: startTime, goalMinutes: 1)
        
        // Verify initial state
        XCTAssertTrue(session.isActive)
        XCTAssertFalse(session.goalMet)
        
        // When: Simulating time passing (goal not yet met)
        // After 30 seconds
        let sessionAfter30Sec = FastingSession(
            startTime: startTime.addingTimeInterval(-30),
            goalMinutes: 1
        )
        XCTAssertTrue(sessionAfter30Sec.isActive)
        XCTAssertFalse(sessionAfter30Sec.goalMet)
        
        // When: Simulating goal being met (after 61 seconds)
        let sessionAfter61Sec = FastingSession(
            startTime: startTime.addingTimeInterval(-61),
            goalMinutes: 1
        )
        XCTAssertTrue(sessionAfter61Sec.isActive)
        XCTAssertTrue(sessionAfter61Sec.goalMet)
        
        // When: Stopping the session
        let finalSession = FastingSession(
            startTime: startTime.addingTimeInterval(-120),
            goalMinutes: 1
        )
        finalSession.stop()
        
        // Then: Session should be complete with goal met
        XCTAssertFalse(finalSession.isActive)
        XCTAssertTrue(finalSession.goalMet)
        XCTAssertNotNil(finalSession.endTime)
    }
    
    func testWorkflow_StopBeforeGoalMet() {
        // Given: A session with 16-hour goal that's only been running 2 hours
        let startTime = Date().addingTimeInterval(-7200) // 2 hours ago
        let session = FastingSession(startTime: startTime, goalMinutes: 960)
        
        // Verify pre-stop state
        XCTAssertTrue(session.isActive)
        XCTAssertFalse(session.goalMet)
        
        // When: Stopping early
        session.stop()
        
        // Then: Session should be stopped but goal not met
        XCTAssertFalse(session.isActive)
        XCTAssertFalse(session.goalMet)
        XCTAssertNotNil(session.endTime)
    }
    
    func testWorkflow_ContinuePastGoal() {
        // Given: A session that has exceeded its goal
        let startTime = Date().addingTimeInterval(-72000) // 20 hours ago
        let session = FastingSession(startTime: startTime, goalMinutes: 960) // 16 hour goal
        
        // Verify state before stopping
        XCTAssertTrue(session.isActive)
        XCTAssertTrue(session.goalMet)
        
        // Duration should exceed goal
        let durationHours = session.duration / 3600
        XCTAssertGreaterThan(durationHours, 16)
        
        // When: Finally stopping
        session.stop()
        
        // Then: Duration should be preserved
        XCTAssertFalse(session.isActive)
        XCTAssertTrue(session.goalMet)
    }
    
    func testMultipleSessions_DontInterfere() {
        // Given: Two separate sessions
        let session1Start = Date().addingTimeInterval(-7200)
        let session2Start = Date().addingTimeInterval(-3600)
        
        let session1 = FastingSession(startTime: session1Start, goalMinutes: 120) // 2 hour goal
        let session2 = FastingSession(startTime: session2Start, goalMinutes: 60)  // 1 hour goal
        
        // When: Stopping session1
        session1.stop()
        
        // Then: Sessions should be independent
        XCTAssertFalse(session1.isActive)
        XCTAssertTrue(session2.isActive) // Should still be active
        XCTAssertNotEqual(session1.id, session2.id)
    }
}

// MARK: - Boundary Tests

final class BoundaryTests: XCTestCase {
    
    func testGoalBoundary_ExactlyAtGoalTime() {
        // Given: A session exactly at goal time (edge case)
        let goalMinutes = 60 // 1 hour
        let elapsedSeconds = 3600 // Exactly 1 hour
        let startTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking goal met
        let goalMet = session.goalMet
        
        // Then: Goal should be met at exactly goal time
        XCTAssertTrue(goalMet)
    }
    
    func testGoalBoundary_OneSecondBeforeGoal() {
        // Given: A session one second before goal
        let goalMinutes = 60 // 1 hour
        let elapsedSeconds = 3599 // 1 second before 1 hour
        let startTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking goal met
        let goalMet = session.goalMet
        
        // Then: Goal should NOT be met (needs full minute)
        XCTAssertFalse(goalMet)
    }
    
    func testLargeGoalValue() {
        // Given: A very large goal (7 days)
        let goalMinutes = 7 * 24 * 60 // 7 days in minutes
        let startTime = Date().addingTimeInterval(-Double(goalMinutes * 60))
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking calculations
        let goalMet = session.goalMet
        let duration = session.duration
        
        // Then: Should handle large values correctly
        XCTAssertTrue(goalMet)
        XCTAssertEqual(duration, TimeInterval(goalMinutes * 60), accuracy: 1.0)
    }
    
    func testMinimumGoalValue() {
        // Given: Minimum practical goal (1 minute)
        let goalMinutes = 1
        let startTime = Date().addingTimeInterval(-60)
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking goal met
        let goalMet = session.goalMet
        
        // Then: Should work correctly
        XCTAssertTrue(goalMet)
    }
}
