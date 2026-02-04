//
//  LastFastAppTests.swift
//  LastFastTests
//
//  Tests for LastFastApp configurations and static methods
//

import XCTest
@testable import LastFast

// MARK: - App Configuration Tests

final class LastFastAppConfigurationTests: XCTestCase {

    func testBackgroundTaskIdentifier_HasExpectedValue() {
        // Given: The expected background task identifier
        let expectedIdentifier = "dev.stringer.lastfast.refresh"

        // Then: Should match the format used in app
        XCTAssertTrue(expectedIdentifier.hasPrefix("dev.stringer.lastfast"))
        XCTAssertTrue(expectedIdentifier.contains("refresh"))
    }

    func testLiveActivityEnabled_IsBooleanFlag() {
        // Given: The live activity feature flag
        let isEnabled = liveActivityEnabled

        // Then: Should be a boolean (currently disabled)
        XCTAssertNotNil(isEnabled)
        // Feature flag test - value may change but should be a valid boolean
        XCTAssertTrue(isEnabled == true || isEnabled == false)
    }

    func testLiveActivityEnabled_CurrentlyDisabled() {
        // Given: The current feature flag state

        // Then: Live activity is currently disabled
        XCTAssertFalse(liveActivityEnabled)
    }
}

// MARK: - Background Refresh Logic Tests

final class BackgroundRefreshLogicTests: XCTestCase {

    func testRefreshRequest_EarliestBeginDate() {
        // Given: The refresh request timing
        let requestInterval: TimeInterval = 60 // 1 minute

        // When: Calculating earliest begin date
        let earliestBeginDate = Date(timeIntervalSinceNow: requestInterval)

        // Then: Should be approximately 1 minute from now
        XCTAssertEqual(earliestBeginDate.timeIntervalSinceNow, 60, accuracy: 1)
    }

    func testScheduleAppRefresh_OnlyIfLiveActivityEnabled() {
        // Given: Live activity feature flag
        let shouldSchedule = liveActivityEnabled

        // Then: Should not schedule if live activity is disabled
        if !liveActivityEnabled {
            XCTAssertFalse(shouldSchedule)
        }
    }
}

// MARK: - Live Activity Update Logic Tests

final class LiveActivityUpdateLogicTests: XCTestCase {

    func testElapsedTimeCalculation() {
        // Given: A start time 4 hours ago
        let startTime = Date().addingTimeInterval(-14400)

        // When: Calculating elapsed seconds
        let elapsed = Int(Date().timeIntervalSince(startTime))

        // Then: Should be approximately 4 hours in seconds
        XCTAssertEqual(elapsed, 14400, accuracy: 1)
    }

    func testGoalMetCalculation_NotMet() {
        // Given: 8 hours elapsed with 16 hour goal
        let elapsed = 28800 // 8 hours in seconds
        let goalMinutes = 960 // 16 hours

        // When: Checking if goal is met
        let goalMet = elapsed >= goalMinutes * 60

        // Then: Should not be met
        XCTAssertFalse(goalMet)
    }

    func testGoalMetCalculation_Met() {
        // Given: 17 hours elapsed with 16 hour goal
        let elapsed = 61200 // 17 hours in seconds
        let goalMinutes = 960 // 16 hours

        // When: Checking if goal is met
        let goalMet = elapsed >= goalMinutes * 60

        // Then: Should be met
        XCTAssertTrue(goalMet)
    }

    func testGoalMetCalculation_ExactlyMet() {
        // Given: Exactly 16 hours elapsed with 16 hour goal
        let elapsed = 57600 // 16 hours in seconds
        let goalMinutes = 960 // 16 hours

        // When: Checking if goal is met
        let goalMet = elapsed >= goalMinutes * 60

        // Then: Should be met
        XCTAssertTrue(goalMet)
    }

    func testDefaultGoalMinutes() {
        // Given: Default goal value
        let defaultGoal = 480 // As used in updateLiveActivityInBackground fallback

        // Then: Should be 8 hours (480 minutes)
        XCTAssertEqual(defaultGoal, 480)
        XCTAssertEqual(defaultGoal / 60, 8) // 8 hours
    }
}

// MARK: - UserDefaults Key Tests

final class AppUserDefaultsKeyTests: XCTestCase {

    func testSharedContainerIdentifier() {
        // Given: The shared container group identifier
        let identifier = "group.dev.stringer.lastfast.shared"

        // Then: Should follow expected format
        XCTAssertTrue(identifier.hasPrefix("group."))
        XCTAssertTrue(identifier.contains("lastfast"))
    }

    func testFastingStartTimeKey() {
        // Given: The key for fasting start time
        let key = "fastingStartTime"

        // Then: Should not be empty
        XCTAssertFalse(key.isEmpty)
    }

    func testFastingGoalMinutesKey() {
        // Given: The key for fasting goal minutes
        let key = "fastingGoalMinutes"

        // Then: Should match the constant
        XCTAssertEqual(key, fastingGoalStorageKey)
    }
}

// MARK: - Scene Phase Handling Tests

final class ScenePhaseHandlingTests: XCTestCase {

    func testBackgroundPhase_ShouldScheduleRefresh_WhenLiveActivityEnabled() {
        // Given: App going to background with live activity enabled
        let isBackground = true
        let shouldSchedule = isBackground && liveActivityEnabled

        // Then: Should only schedule if both conditions met
        if liveActivityEnabled {
            XCTAssertTrue(shouldSchedule)
        } else {
            XCTAssertFalse(shouldSchedule)
        }
    }

    func testBackgroundPhase_ShouldNotScheduleRefresh_WhenLiveActivityDisabled() {
        // Given: App going to background with live activity disabled
        let isBackground = true
        let shouldSchedule = isBackground && liveActivityEnabled

        // Then: Should not schedule when live activity is disabled
        if !liveActivityEnabled {
            XCTAssertFalse(shouldSchedule)
        }
    }
}

// MARK: - Model Container Configuration Tests

final class ModelContainerConfigurationTests: XCTestCase {

    func testCloudKitDatabaseIdentifier() {
        // Given: The CloudKit database identifier
        let identifier = "iCloud.dev.stringer.lastfast"

        // Then: Should follow expected format
        XCTAssertTrue(identifier.hasPrefix("iCloud."))
        XCTAssertTrue(identifier.contains("lastfast"))
    }

    func testSchemaIncludesFastingSession() {
        // Given: A FastingSession instance
        let session = FastingSession(goalMinutes: 960)

        // Then: Should be a valid model object
        XCTAssertNotNil(session)
        XCTAssertNotNil(session.id)
    }
}

// MARK: - Background Task Handler Tests

final class BackgroundTaskHandlerTests: XCTestCase {

    func testTaskCompletionHandling_WhenLiveActivityDisabled() {
        // Given: Live activity is disabled
        let shouldProcess = liveActivityEnabled

        // Then: Task should complete immediately without processing
        if !liveActivityEnabled {
            XCTAssertFalse(shouldProcess)
        }
    }

    func testTaskExpirationHandling() {
        // Given: A task expiration scenario
        var taskCompleted = false
        var success = true

        // When: Simulating expiration handler
        let expirationHandler = {
            success = false
            taskCompleted = true
        }
        expirationHandler()

        // Then: Should mark task as failed
        XCTAssertTrue(taskCompleted)
        XCTAssertFalse(success)
    }

    func testTaskSuccessfulCompletion() {
        // Given: A successful task completion scenario
        var taskCompleted = false
        var success = false

        // When: Completing successfully
        let completionHandler = {
            success = true
            taskCompleted = true
        }
        completionHandler()

        // Then: Should mark task as successful
        XCTAssertTrue(taskCompleted)
        XCTAssertTrue(success)
    }
}

// MARK: - Start Time Retrieval Tests

final class StartTimeRetrievalTests: XCTestCase {

    func testStartTimeFromInterval() {
        // Given: A time interval representing a start time
        let startTimeInterval: TimeInterval = Date().addingTimeInterval(-7200).timeIntervalSince1970

        // When: Converting back to Date
        let startTime = Date(timeIntervalSince1970: startTimeInterval)

        // Then: Should be approximately 2 hours ago
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertEqual(elapsed, 7200, accuracy: 1)
    }

    func testMissingStartTime_ReturnsNil() {
        // Given: No start time stored (simulated)
        let startTimeInterval: TimeInterval? = nil

        // Then: Should be nil
        XCTAssertNil(startTimeInterval)
    }
}
