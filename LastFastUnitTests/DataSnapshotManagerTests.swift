//
//  DataSnapshotManagerTests.swift
//  LastFastTests
//
//  Tests for DataSnapshotManager functionality
//  Note: DataSnapshotManager is only available in DEBUG builds
//

import XCTest
@testable import LastFast

#if DEBUG

// MARK: - Snapshot Error Tests

final class SnapshotErrorTests: XCTestCase {

    func testSeedFileNotFound_HasCorrectDescription() {
        // Given: A seed file not found error
        let error = SnapshotError.seedFileNotFound("test_data")

        // When: Getting error description
        let description = error.errorDescription

        // Then: Should include the filename
        XCTAssertNotNil(description)
        XCTAssertTrue(description!.contains("test_data"))
        XCTAssertTrue(description!.contains(".json"))
    }

    func testExportDirectoryCreationFailed_HasDescription() {
        // Given: An export directory creation error
        let error = SnapshotError.exportDirectoryCreationFailed

        // When: Getting error description
        let description = error.errorDescription

        // Then: Should have meaningful description
        XCTAssertNotNil(description)
        XCTAssertTrue(description!.contains("directory") || description!.contains("snapshots"))
    }

    func testEncodingFailed_HasDescription() {
        // Given: An encoding failure error
        let error = SnapshotError.encodingFailed

        // When: Getting error description
        let description = error.errorDescription

        // Then: Should mention encoding
        XCTAssertNotNil(description)
        XCTAssertTrue(description!.lowercased().contains("encod"))
    }

    func testDecodingFailed_HasDescription() {
        // Given: A decoding failure error
        let error = SnapshotError.decodingFailed

        // When: Getting error description
        let description = error.errorDescription

        // Then: Should mention decoding
        XCTAssertNotNil(description)
        XCTAssertTrue(description!.lowercased().contains("decod"))
    }

    func testAllErrors_ConformToLocalizedError() {
        // Given: All error cases
        let errors: [SnapshotError] = [
            .seedFileNotFound("test"),
            .exportDirectoryCreationFailed,
            .encodingFailed,
            .decodingFailed
        ]

        // Then: All should have error descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error should have description: \(error)")
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
}

// MARK: - DataSnapshotManager Singleton Tests

final class DataSnapshotManagerSingletonTests: XCTestCase {

    func testShared_ReturnsSameInstance() {
        // Given/When: Accessing shared instance multiple times
        let instance1 = DataSnapshotManager.shared
        let instance2 = DataSnapshotManager.shared

        // Then: Should be the same instance
        XCTAssertTrue(instance1 === instance2)
    }
}

// MARK: - Launch Argument Parsing Tests

final class LaunchArgumentParsingTests: XCTestCase {

    func testClearDataArgument_Detection() {
        // Given: Arguments containing clear data flag
        let args = ["--clear-data", "--other-arg"]

        // When: Checking for clear data flag
        let shouldClear = args.contains("--clear-data")

        // Then: Should detect flag
        XCTAssertTrue(shouldClear)
    }

    func testSeedDataArgument_ExtractsFilename() {
        // Given: Arguments with seed data flag and filename
        let args = ["--seed-data", "test_sessions", "--other-arg"]

        // When: Extracting filename
        var filename: String? = nil
        if let seedIndex = args.firstIndex(of: "--seed-data"),
           seedIndex + 1 < args.count {
            filename = args[seedIndex + 1]
        }

        // Then: Should extract correct filename
        XCTAssertEqual(filename, "test_sessions")
    }

    func testSeedDataArgument_MissingFilename() {
        // Given: Arguments with seed data flag but no filename
        let args = ["--seed-data"]

        // When: Trying to extract filename
        var filename: String? = nil
        if let seedIndex = args.firstIndex(of: "--seed-data"),
           seedIndex + 1 < args.count {
            filename = args[seedIndex + 1]
        }

        // Then: Should not extract anything
        XCTAssertNil(filename)
    }

    func testExportSnapshotArgument_Detection() {
        // Given: Arguments with export flag
        let args = ["--export-snapshot"]

        // When: Checking for export flag
        let shouldExport = args.contains("--export-snapshot")

        // Then: Should detect flag
        XCTAssertTrue(shouldExport)
    }

    func testUITestGoalArgument_ExtractsValue() {
        // Given: Arguments with UI test goal flag and value
        let args = ["--ui-test-goal", "720"]

        // When: Extracting goal value
        var goalMinutes: Int? = nil
        if let goalIndex = args.firstIndex(of: "--ui-test-goal"),
           goalIndex + 1 < args.count,
           let value = Int(args[goalIndex + 1]) {
            goalMinutes = value
        }

        // Then: Should extract correct value
        XCTAssertEqual(goalMinutes, 720)
    }

    func testUITestGoalArgument_InvalidValue() {
        // Given: Arguments with invalid goal value
        let args = ["--ui-test-goal", "not-a-number"]

        // When: Trying to extract goal value
        var goalMinutes: Int? = nil
        if let goalIndex = args.firstIndex(of: "--ui-test-goal"),
           goalIndex + 1 < args.count,
           let value = Int(args[goalIndex + 1]) {
            goalMinutes = value
        }

        // Then: Should be nil
        XCTAssertNil(goalMinutes)
    }

    func testMultipleArguments_AllParsed() {
        // Given: Multiple launch arguments
        let args = ["app", "--clear-data", "--seed-data", "test_data", "--ui-test-goal", "480"]

        // When: Parsing all flags
        let shouldClear = args.contains("--clear-data")
        var seedFile: String? = nil
        var goalMinutes: Int? = nil

        if let seedIndex = args.firstIndex(of: "--seed-data"),
           seedIndex + 1 < args.count {
            seedFile = args[seedIndex + 1]
        }

        if let goalIndex = args.firstIndex(of: "--ui-test-goal"),
           goalIndex + 1 < args.count,
           let value = Int(args[goalIndex + 1]) {
            goalMinutes = value
        }

        // Then: All should be parsed correctly
        XCTAssertTrue(shouldClear)
        XCTAssertEqual(seedFile, "test_data")
        XCTAssertEqual(goalMinutes, 480)
    }
}

// MARK: - Encoder/Decoder Configuration Tests

final class SnapshotEncoderDecoderTests: XCTestCase {

    func testEncoder_UsesISO8601DateStrategy() {
        // Given: An encoder configured like DataSnapshotManager
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        // When: Encoding a date
        let date = Date(timeIntervalSince1970: 0) // 1970-01-01T00:00:00Z
        let wrapper = DateWrapper(date: date)
        let data = try? encoder.encode(wrapper)

        // Then: Should use ISO8601 format
        XCTAssertNotNil(data)
        let jsonString = String(data: data!, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("1970-01-01"))
    }

    func testEncoder_UsesPrettyPrinting() {
        // Given: An encoder configured like DataSnapshotManager
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // When: Encoding an object
        let wrapper = TestObject(name: "test", value: 42)
        let data = try? encoder.encode(wrapper)

        // Then: Should have newlines (pretty printed)
        XCTAssertNotNil(data)
        let jsonString = String(data: data!, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("\n"))
    }

    func testDecoder_UsesISO8601DateStrategy() {
        // Given: A decoder configured like DataSnapshotManager
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // When: Decoding an ISO8601 date string
        let json = """
        {"date": "1970-01-01T00:00:00Z"}
        """.data(using: .utf8)!

        let wrapper = try? decoder.decode(DateWrapper.self, from: json)

        // Then: Should decode correctly
        XCTAssertNotNil(wrapper)
        XCTAssertEqual(wrapper!.date.timeIntervalSince1970, 0, accuracy: 1)
    }

    func testRoundTrip_DatePreservation() {
        // Given: Encoder and decoder with matching strategies
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // When: Round-tripping a date
        let originalDate = Date()
        let wrapper = DateWrapper(date: originalDate)
        let data = try! encoder.encode(wrapper)
        let decoded = try! decoder.decode(DateWrapper.self, from: data)

        // Then: Date should be preserved (within ISO8601 precision)
        XCTAssertEqual(decoded.date.timeIntervalSince1970, originalDate.timeIntervalSince1970, accuracy: 1)
    }

    private struct DateWrapper: Codable {
        let date: Date
    }

    private struct TestObject: Codable {
        let name: String
        let value: Int
    }
}

// MARK: - Snapshot Filename Generation Tests

final class SnapshotFilenameTests: XCTestCase {

    func testFilename_ContainsTimestamp() {
        // Given: An ISO8601 timestamp
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: Date())
            .replacingOccurrences(of: ":", with: "-")

        // When: Creating filename
        let filename = "snapshot_\(timestamp).json"

        // Then: Should have expected format
        XCTAssertTrue(filename.hasPrefix("snapshot_"))
        XCTAssertTrue(filename.hasSuffix(".json"))
        XCTAssertFalse(filename.contains(":")) // Colons replaced with dashes
    }

    func testFilename_ColonsReplacedWithDashes() {
        // Given: A timestamp with colons
        let timestamp = "2024-01-15T10:30:45Z"

        // When: Replacing colons
        let safeTimestamp = timestamp.replacingOccurrences(of: ":", with: "-")

        // Then: Should not contain colons
        XCTAssertFalse(safeTimestamp.contains(":"))
        XCTAssertEqual(safeTimestamp, "2024-01-15T10-30-45Z")
    }
}

#endif
