//
//  FastingUITests.swift
//  LastFastUITests
//
//  UI tests for fasting workflow scenarios
//

import XCTest

final class FastingUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()

        // Clear any existing data and set 1 minute goal for testing
        app.launchArguments = ["--clear-data", "--ui-test-goal", "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Scenario 1: Start and Stop Fast After 5 Seconds

    /// Test starting a fast and stopping it after 5 seconds before goal is met.
    /// Verifies: Start screen -> Active fasting screen -> Stop confirmation -> Return to start screen
    func testStartAndStopFastBeforeGoalMet() throws {
        app.launch()

        // MARK: Verify Start Screen
        // Should see the "FAST GOAL" label indicating we're on the start screen
        let fastGoalLabel = app.staticTexts["fastGoalLabel"]
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Should see FAST GOAL label on start screen")

        // Should see the Start Fast button
        let startButton = app.buttons["startFastButton"]
        XCTAssertTrue(startButton.exists, "Should see Start Fast button")
        XCTAssertTrue(startButton.isHittable, "Start Fast button should be tappable")

        // MARK: Start the Fast
        startButton.tap()

        // MARK: Verify Active Fasting Screen (Goal Not Met)
        // Should see "FAST UNTIL" header indicating active fast
        let fastUntilHeader = app.staticTexts["fastUntilHeader"]
        XCTAssertTrue(fastUntilHeader.waitForExistence(timeout: 5), "Should see FAST UNTIL header after starting fast")

        // Should see the active goal label
        let activeGoalLabel = app.staticTexts["activeGoalLabel"]
        XCTAssertTrue(activeGoalLabel.waitForExistence(timeout: 2), "Should see goal label during active fast")

        // Should see Stop Fast button
        let stopButton = app.buttons["stopFastButton"]
        XCTAssertTrue(stopButton.exists, "Should see Stop Fast button during active fast")

        // MARK: Wait 5 Seconds (goal is 1 minute, so we're stopping before goal met)
        sleep(5)

        // Verify we're still in active fasting state (goal not met yet)
        XCTAssertTrue(fastUntilHeader.exists, "Should still show FAST UNTIL header (goal not met)")
        XCTAssertFalse(app.staticTexts["goalMetHeader"].exists, "Should NOT show goal met header yet")

        // MARK: Stop the Fast
        stopButton.tap()

        // MARK: Verify Stop Confirmation Alert
        let stopAlert = app.alerts["Stop Fast?"]
        XCTAssertTrue(stopAlert.waitForExistence(timeout: 3), "Should see stop confirmation alert")

        // Tap "Stop Fast" to confirm
        let confirmButton = stopAlert.buttons["Stop Fast"]
        XCTAssertTrue(confirmButton.exists, "Should see Stop Fast confirmation button")
        confirmButton.tap()

        // MARK: Verify Return to Start Screen
        // Should be back on start screen with "FAST GOAL" label
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Should return to start screen with FAST GOAL label")
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Should see Start Fast button again")
        XCTAssertFalse(stopButton.exists, "Stop Fast button should no longer exist")
    }

    // MARK: - Scenario 2: Start Fast, Observe Goal Met, Then Stop

    /// Test starting a fast, waiting for goal to be met (1 minute), then stopping after 1:05.
    /// Verifies: Start screen -> Active fasting -> Goal met state -> Stop -> Return to start screen
    func testStartFastObserveGoalMetThenStop() throws {
        app.launch()

        // MARK: Verify Start Screen
        let fastGoalLabel = app.staticTexts["fastGoalLabel"]
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Should see FAST GOAL label on start screen")

        let startButton = app.buttons["startFastButton"]
        XCTAssertTrue(startButton.exists, "Should see Start Fast button")

        // MARK: Start the Fast
        startButton.tap()

        // MARK: Verify Active Fasting Screen (Goal Not Met Initially)
        let fastUntilHeader = app.staticTexts["fastUntilHeader"]
        XCTAssertTrue(fastUntilHeader.waitForExistence(timeout: 5), "Should see FAST UNTIL header after starting fast")

        let activeGoalLabel = app.staticTexts["activeGoalLabel"]
        XCTAssertTrue(activeGoalLabel.waitForExistence(timeout: 2), "Should see goal label during active fast")

        let stopButton = app.buttons["stopFastButton"]
        XCTAssertTrue(stopButton.exists, "Should see Stop Fast button")

        // MARK: Wait for Goal to be Met (1 minute + buffer)
        // Goal is 1 minute, so we wait 62 seconds to ensure goal is met
        let goalMetHeader = app.staticTexts["goalMetHeader"]
        let goalMetCheckmark = app.staticTexts["goalMetCheckmark"]

        // Wait up to 70 seconds for goal to be met
        XCTAssertTrue(goalMetHeader.waitForExistence(timeout: 70), "Should see YOU'VE FASTED FOR header when goal is met")

        // MARK: Verify Goal Met State
        XCTAssertTrue(goalMetCheckmark.waitForExistence(timeout: 5), "Should see goal met checkmark")
        XCTAssertFalse(fastUntilHeader.exists, "FAST UNTIL header should no longer be visible")
        XCTAssertTrue(stopButton.exists, "Stop Fast button should still be visible")

        // MARK: Wait Additional 5 Seconds (total ~1:05)
        sleep(5)

        // Verify still in goal met state
        XCTAssertTrue(goalMetHeader.exists, "Should still show goal met header")
        XCTAssertTrue(goalMetCheckmark.exists, "Should still show goal met checkmark")

        // MARK: Stop the Fast
        stopButton.tap()

        // MARK: Verify Stop Confirmation Alert
        let stopAlert = app.alerts["Stop Fast?"]
        XCTAssertTrue(stopAlert.waitForExistence(timeout: 3), "Should see stop confirmation alert")

        let confirmButton = stopAlert.buttons["Stop Fast"]
        XCTAssertTrue(confirmButton.exists, "Should see Stop Fast confirmation button")
        confirmButton.tap()

        // MARK: Verify Return to Start Screen
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Should return to start screen with FAST GOAL label")
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Should see Start Fast button again")
        XCTAssertFalse(goalMetHeader.exists, "Goal met header should no longer exist")
        XCTAssertFalse(stopButton.exists, "Stop Fast button should no longer exist")
    }
}
