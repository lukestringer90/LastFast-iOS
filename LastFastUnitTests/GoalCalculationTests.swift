//
//  GoalCalculationTests.swift
//  LastFastTests
//
//  Tests for goal and progress calculations
//

import XCTest
@testable import LastFast

final class GoalCalculationTests: XCTestCase {
    
    func testRemainingMinutes_WhenHalfwayToGoal() {
        // Given: A 16-hour goal with 8 hours elapsed
        let goalMinutes = 960
        let elapsedSeconds = 8 * 3600
        
        // When: Calculating remaining minutes
        let elapsedMinutes = elapsedSeconds / 60
        let remainingMinutes = max(0, goalMinutes - elapsedMinutes)
        
        // Then: Should have 8 hours remaining
        XCTAssertEqual(remainingMinutes, 480)
    }
    
    func testRemainingMinutes_WhenGoalExceeded_ReturnsZero() {
        // Given: A 16-hour goal with 20 hours elapsed
        let goalMinutes = 960
        let elapsedSeconds = 20 * 3600
        
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
            (3599, 0),
            (3600, 1),
            (7200, 2),
            (36000, 10),
            (86400, 24),
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
            (59, 0),
            (60, 1),
            (3599, 59),
            (3660, 1),
            (7380, 3),
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
            (480, 8, 0),
            (495, 8, 15),
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
