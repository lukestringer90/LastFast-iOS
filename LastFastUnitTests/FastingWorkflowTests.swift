//
//  FastingWorkflowTests.swift
//  LastFastTests
//
//  Integration-style tests for fasting workflows
//

import XCTest
@testable import LastFast

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
        let session = TestSessionFactory.typicalFast(startedHoursAgo: 2)

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
        // Given: A session that has exceeded its 16-hour goal (20 hours elapsed)
        let session = TestSessionFactory.typicalFast(startedHoursAgo: 20)

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
        // Given: Two separate sessions using factory
        let session1 = TestSessionFactory.activeSession(startedMinutesAgo: 120, goalMinutes: 120)
        let session2 = TestSessionFactory.activeSession(startedMinutesAgo: 60, goalMinutes: 60)

        // When: Stopping session1
        session1.stop()

        // Then: Sessions should be independent
        XCTAssertFalse(session1.isActive)
        XCTAssertTrue(session2.isActive)
        XCTAssertNotEqual(session1.id, session2.id)
    }

    // MARK: - Additional Workflow Tests

    func testWorkflow_ExactlyAtGoal_GoalIsMet() {
        // Given: A session exactly at its goal time
        let session = TestSessionFactory.sessionAtGoal(goalMinutes: 60)

        // When: Checking goal status
        let goalMet = session.goalMet

        // Then: Goal should be met
        XCTAssertTrue(goalMet)
        XCTAssertTrue(session.isActive)
    }

    func testWorkflow_CompletedSessionWithGoalMet() {
        // Given: A completed session that met its goal
        let session = TestSessionFactory.completedSession(durationMinutes: 120, goalMinutes: 60)

        // Then: Should be complete and goal met
        XCTAssertFalse(session.isActive)
        XCTAssertTrue(session.goalMet)
        XCTAssertNotNil(session.endTime)
    }

    func testWorkflow_CompletedSessionWithoutMeetingGoal() {
        // Given: A completed session that didn't meet its goal
        let session = TestSessionFactory.completedSession(durationMinutes: 30, goalMinutes: 60)

        // Then: Should be complete but goal not met
        XCTAssertFalse(session.isActive)
        XCTAssertFalse(session.goalMet)
        XCTAssertNotNil(session.endTime)
    }

    func testWorkflow_SessionWithNoGoal() {
        // Given: A session without any goal
        let session = TestSessionFactory.activeSession(startedMinutesAgo: 120, goalMinutes: nil)

        // Then: Goal should never be met (no goal to meet)
        XCTAssertFalse(session.goalMet)
        XCTAssertTrue(session.isActive)
        XCTAssertNil(session.goalMinutes)
    }

    func testWorkflow_GoalCelebrationTracking() {
        // Given: A session that has met its goal
        let session = TestSessionFactory.sessionAtGoal(goalMinutes: 60)
        XCTAssertFalse(session.goalCelebrationShown)

        // When: Marking celebration as shown
        session.goalCelebrationShown = true

        // Then: Should persist across accesses
        XCTAssertTrue(session.goalCelebrationShown)
        XCTAssertTrue(session.goalMet)
    }
}

// MARK: - Boundary Tests

final class BoundaryTests: XCTestCase {

    func testGoalBoundary_ExactlyAtGoalTime() {
        // Given: A session exactly at goal time using factory
        let session = TestSessionFactory.sessionAtGoal(goalMinutes: 60)

        // When: Checking goal met
        let goalMet = session.goalMet

        // Then: Goal should be met at exactly goal time
        XCTAssertTrue(goalMet)
    }

    func testGoalBoundary_OneSecondBeforeGoal() {
        // Given: A session one second before goal (59 minutes 59 seconds)
        let startTime = Date().addingTimeInterval(-3599)
        let session = FastingSession(startTime: startTime, goalMinutes: 60)

        // When: Checking goal met
        let goalMet = session.goalMet

        // Then: Goal should NOT be met (needs full minute)
        XCTAssertFalse(goalMet)
    }

    func testGoalBoundary_OneSecondAfterGoal() {
        // Given: A session one second after goal (60 minutes 1 second)
        let startTime = Date().addingTimeInterval(-3601)
        let session = FastingSession(startTime: startTime, goalMinutes: 60)

        // When: Checking goal met
        let goalMet = session.goalMet

        // Then: Goal should be met
        XCTAssertTrue(goalMet)
    }

    func testLargeGoalValue() {
        // Given: A very large goal (7 days)
        let goalMinutes = 7 * 24 * 60
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
        // Given: Minimum practical goal (1 minute) using factory
        let session = TestSessionFactory.sessionAtGoal(goalMinutes: 1)

        // When: Checking goal met
        let goalMet = session.goalMet

        // Then: Should work correctly
        XCTAssertTrue(goalMet)
    }

    func testZeroGoalValue() {
        // Given: Zero goal (edge case)
        let session = FastingSession(goalMinutes: 0)

        // When: Checking goal met immediately
        let goalMet = session.goalMet

        // Then: Goal should be met (0 >= 0)
        XCTAssertTrue(goalMet)
    }

    func testNegativeDuration_FutureStartTime() {
        // Given: A session with future start time
        let futureStart = Date().addingTimeInterval(3600)
        let session = FastingSession(startTime: futureStart, goalMinutes: 60)

        // When: Getting duration
        let duration = session.duration

        // Then: Duration should be negative
        XCTAssertLessThan(duration, 0)
        XCTAssertFalse(session.goalMet)
    }

    func testVeryShortDuration() {
        // Given: A session with very short duration (1 second)
        let startTime = Date().addingTimeInterval(-1)
        let session = FastingSession(startTime: startTime, goalMinutes: 60)

        // When: Checking state
        let duration = session.duration
        let goalMet = session.goalMet

        // Then: Should handle correctly
        XCTAssertEqual(duration, 1.0, accuracy: 0.5)
        XCTAssertFalse(goalMet)
    }
}

// MARK: - Test Helper Usage Tests

final class TestHelperTests: XCTestCase {

    func testTestDateBuilder_CreatesCorrectDate() {
        // Given: Using the test date builder
        let date = TestDateBuilder.date(hour: 14, minute: 30)

        // When: Extracting components
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)

        // Then: Components should match
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
    }

    func testTestDateBuilder_DateAgo() {
        // Given: A date 2 hours ago
        let twoHoursAgo = TestDateBuilder.dateAgo(hours: 2)
        let now = Date()

        // When: Calculating difference
        let difference = now.timeIntervalSince(twoHoursAgo)

        // Then: Should be approximately 2 hours
        XCTAssertEqual(difference, 7200, accuracy: 1.0)
    }

    func testTestSessionFactory_ActiveSession() {
        // Given: An active session from factory
        let session = TestSessionFactory.activeSession(startedMinutesAgo: 30, goalMinutes: 60)

        // Then: Should be configured correctly
        XCTAssertTrue(session.isActive)
        XCTAssertEqual(session.goalMinutes, 60)
        XCTAssertEqual(session.duration, 1800, accuracy: 1.0)
    }

    func testTestSessionFactory_CompletedSession() {
        // Given: A completed session from factory
        let session = TestSessionFactory.completedSession(durationMinutes: 120, goalMinutes: 60)

        // Then: Should be stopped with goal met
        XCTAssertFalse(session.isActive)
        XCTAssertTrue(session.goalMet)
        XCTAssertNotNil(session.endTime)
    }

    func testTestSessionFactory_TypicalFast() {
        // Given: A typical fast from factory
        let session = TestSessionFactory.typicalFast(startedHoursAgo: 8)

        // Then: Should have 16-hour goal, started 8 hours ago
        XCTAssertEqual(session.goalMinutes, 960)
        XCTAssertEqual(session.duration, 8 * 3600, accuracy: 1.0)
        XCTAssertFalse(session.goalMet)
    }
}
