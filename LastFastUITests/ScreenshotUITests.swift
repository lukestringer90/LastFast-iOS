//
//  ScreenshotUITests.swift
//  LastFastUITests
//
//  Automated App Store screenshot capture
//

import XCTest

final class ScreenshotUITests: XCTestCase {

    var app: XCUIApplication!

    // Output directory from environment or default
    private var screenshotDirectory: String {
        ProcessInfo.processInfo.environment["SCREENSHOT_OUTPUT_DIR"]
            ?? NSTemporaryDirectory() + "LastFast_Screenshots"
    }

    // Detect color mode from launch arguments
    private var colorMode: String {
        ProcessInfo.processInfo.environment["SCREENSHOT_COLOR_MODE"] ?? "light"
    }

    override func setUpWithError() throws {
        continueAfterFailure = true // Continue capturing remaining screenshots if one fails
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Screenshot Helpers

    private func captureScreenshot(named name: String) {
        // Allow UI to settle
        Thread.sleep(forTimeInterval: 0.5)

        let screenshot = XCUIScreen.main.screenshot()

        // Attach to test results (visible in Xcode)
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to filesystem
        saveScreenshotToFile(screenshot, named: name)
    }

    private func saveScreenshotToFile(_ screenshot: XCUIScreenshot, named name: String) {
        let fileManager = FileManager.default
        let outputDir = URL(fileURLWithPath: screenshotDirectory)

        try? fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let filename = "\(deviceSizeName())_\(name)_\(colorMode).png"
        let filePath = outputDir.appendingPathComponent(filename)

        do {
            try screenshot.pngRepresentation.write(to: filePath)
            print("Screenshot saved: \(filePath.path)")
        } catch {
            print("Failed to save screenshot: \(error)")
        }
    }

    private func deviceSizeName() -> String {
        // Get device name from environment variable set by capture script
        if let deviceName = ProcessInfo.processInfo.environment["SCREENSHOT_DEVICE_NAME"] {
            // Convert device name to App Store size
            if deviceName.contains("Pro Max") {
                return "6.9-inch"
            } else if deviceName.contains("Plus") {
                return "6.7-inch"
            } else if deviceName.contains("Pro") {
                return "6.3-inch"
            }
            // Sanitize for filename
            return deviceName.replacingOccurrences(of: " ", with: "_")
        }

        // Fallback: use window frame after app launch
        let frame = app.windows.firstMatch.frame
        let height = max(frame.width, frame.height)

        // Map point heights to device sizes (approximate)
        switch Int(height) {
        case 956: return "6.9-inch"   // iPhone 16 Pro Max
        case 932: return "6.7-inch"   // iPhone 14/15/16 Plus
        case 852: return "6.1-inch"   // iPhone 14/15/16 Pro
        case 844: return "6.1-inch"   // iPhone 12/13/14
        default: return "unknown-\(Int(height))"
        }
    }

    private func configureLaunchArguments(seedData: String) {
        app.launchArguments = [
            "--clear-data",
            "--skip-onboarding",
            "--seed-data", seedData
        ]

        // Add color mode argument
        if colorMode == "dark" {
            app.launchArguments.append("--dark-mode")
        } else {
            app.launchArguments.append("--light-mode")
        }
    }

    // MARK: - Screenshot Tests

    /// Screenshot 1: Not Fasting State
    /// Clean main screen with goal display and "Start Fast" button
    func testScreenshot_01_NotFasting() throws {
        configureLaunchArguments(seedData: "screenshot_history")
        app.launch()

        // Wait for main screen to appear
        let fastGoalLabel = app.staticTexts["fastGoalLabel"]
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 10), "Main screen should appear")

        captureScreenshot(named: "01_not_fasting")
    }

    /// Screenshot 2: Actively Fasting (mid-progress ~60%)
    /// Progress ring showing active fast, timer countdown
    func testScreenshot_02_ActivelyFasting() throws {
        configureLaunchArguments(seedData: "screenshot_active_fast")
        app.launch()

        // Wait for active fasting state
        let fastUntilHeader = app.staticTexts["fastUntilHeader"]
        XCTAssertTrue(fastUntilHeader.waitForExistence(timeout: 10), "Active fasting screen should appear")

        captureScreenshot(named: "02_actively_fasting")
    }

    /// Screenshot 3: Goal Met State
    /// Full green ring, "YOU'VE FASTED FOR" header, checkmark
    func testScreenshot_03_GoalMet() throws {
        configureLaunchArguments(seedData: "screenshot_goal_met")
        app.launch()

        // Wait for goal met state
        let goalMetHeader = app.staticTexts["goalMetHeader"]
        XCTAssertTrue(goalMetHeader.waitForExistence(timeout: 10), "Goal met screen should appear")

        // Also verify the checkmark is visible
        let goalMetCheckmark = app.staticTexts["goalMetCheckmark"]
        _ = goalMetCheckmark.waitForExistence(timeout: 2)

        captureScreenshot(named: "03_goal_met")
    }

    /// Screenshot 4: History Graph View
    /// Bar chart showing week of fasts with stats
    func testScreenshot_04_HistoryGraph() throws {
        configureLaunchArguments(seedData: "screenshot_history")
        app.launch()

        // Wait for main screen
        let fastGoalLabel = app.staticTexts["fastGoalLabel"]
        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 10), "Main screen should appear")

        // Navigate to history using the history button
        let historyButton = app.buttons["historyButton"]
        if historyButton.waitForExistence(timeout: 5) {
            historyButton.tap()
        } else {
            // Fallback: try finding by label pattern
            let historyButtonAlt = app.buttons.matching(NSPredicate(format: "label CONTAINS 'h' OR label CONTAINS 'History'")).firstMatch
            if historyButtonAlt.waitForExistence(timeout: 2) {
                historyButtonAlt.tap()
            }
        }

        // Wait for history view to appear
        Thread.sleep(forTimeInterval: 1.0)

        captureScreenshot(named: "04_history_graph")
    }
}
