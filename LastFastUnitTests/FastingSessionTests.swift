//
//  FastingSessionTests.swift
//  LastFastTests
//
//  Tests for FastingSession model
//

import XCTest
@testable import LastFast

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
        let customStartTime = Date().addingTimeInterval(-3600)
        
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
        let startTime = Date().addingTimeInterval(-7200)
        session = FastingSession(startTime: startTime)
        
        // When: Getting duration
        let duration = session.duration
        
        // Then: Duration should be approximately 2 hours
        XCTAssertEqual(duration, 7200, accuracy: 1.0)
    }
    
    func testDuration_ForCompletedSession_ReturnsFixedDuration() {
        // Given: A session started 3 hours ago and stopped 1 hour ago
        let startTime = Date().addingTimeInterval(-10800)
        let endTime = Date().addingTimeInterval(-3600)
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
        let startTime = Date().addingTimeInterval(-28800)
        session = FastingSession(startTime: startTime, goalMinutes: 960)
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should not be met
        XCTAssertFalse(goalMet)
    }
    
    func testGoalMet_WhenDurationEqualsGoal_ReturnsTrue() {
        // Given: A 16-hour goal with exactly 16 hours elapsed
        let startTime = Date().addingTimeInterval(-57600)
        session = FastingSession(startTime: startTime, goalMinutes: 960)
        
        // When: Checking goalMet
        let goalMet = session.goalMet
        
        // Then: Goal should be met
        XCTAssertTrue(goalMet)
    }
    
    func testGoalMet_WhenDurationExceedsGoal_ReturnsTrue() {
        // Given: A 16-hour goal with 20 hours elapsed
        let startTime = Date().addingTimeInterval(-72000)
        session = FastingSession(startTime: startTime, goalMinutes: 960)
        
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
        let startTime = Date().addingTimeInterval(-2700)
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
        let futureStart = Date().addingTimeInterval(3600)
        session = FastingSession(startTime: futureStart, goalMinutes: 60)
        
        // When: Getting duration
        let duration = session.duration
        
        // Then: Duration should be negative
        XCTAssertLessThan(duration, 0)
    }
}
