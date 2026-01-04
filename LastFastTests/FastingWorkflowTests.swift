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
        let startTime = Date().addingTimeInterval(-7200)
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
        let startTime = Date().addingTimeInterval(-72000)
        let session = FastingSession(startTime: startTime, goalMinutes: 960)
        
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
        
        let session1 = FastingSession(startTime: session1Start, goalMinutes: 120)
        let session2 = FastingSession(startTime: session2Start, goalMinutes: 60)
        
        // When: Stopping session1
        session1.stop()
        
        // Then: Sessions should be independent
        XCTAssertFalse(session1.isActive)
        XCTAssertTrue(session2.isActive)
        XCTAssertNotEqual(session1.id, session2.id)
    }
}

// MARK: - Boundary Tests

final class BoundaryTests: XCTestCase {
    
    func testGoalBoundary_ExactlyAtGoalTime() {
        // Given: A session exactly at goal time (edge case)
        let goalMinutes = 60
        let elapsedSeconds = 3600
        let startTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking goal met
        let goalMet = session.goalMet
        
        // Then: Goal should be met at exactly goal time
        XCTAssertTrue(goalMet)
    }
    
    func testGoalBoundary_OneSecondBeforeGoal() {
        // Given: A session one second before goal
        let goalMinutes = 60
        let elapsedSeconds = 3599
        let startTime = Date().addingTimeInterval(-Double(elapsedSeconds))
        
        let session = FastingSession(startTime: startTime, goalMinutes: goalMinutes)
        
        // When: Checking goal met
        let goalMet = session.goalMet
        
        // Then: Goal should NOT be met (needs full minute)
        XCTAssertFalse(goalMet)
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
