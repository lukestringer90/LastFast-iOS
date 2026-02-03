//
//  FastingSessionDTOTests.swift
//  LastFastTests
//
//  Tests for FastingSessionDTO serialization and deserialization
//

import XCTest
@testable import LastFast

final class FastingSessionDTOTests: XCTestCase {

    // MARK: - DTO Creation Tests

    func testDTO_FromSession_CopiesAllProperties() {
        // Given: A fasting session with all properties set
        let session = FastingSession(
            startTime: Date().addingTimeInterval(-3600),
            goalMinutes: 960
        )
        session.endTime = Date()
        session.goalCelebrationShown = true

        // When: Creating a DTO from the session
        let dto = FastingSessionDTO(from: session)

        // Then: All properties should be copied
        XCTAssertEqual(dto.id, session.id)
        XCTAssertEqual(dto.startTime, session.startTime)
        XCTAssertEqual(dto.endTime, session.endTime)
        XCTAssertEqual(dto.goalMinutes, session.goalMinutes)
        XCTAssertEqual(dto.goalCelebrationShown, session.goalCelebrationShown)
    }

    func testDTO_FromSession_HandlesNilEndTime() {
        // Given: An active session (no end time)
        let session = FastingSession(goalMinutes: 960)

        // When: Creating a DTO
        let dto = FastingSessionDTO(from: session)

        // Then: End time should be nil
        XCTAssertNil(dto.endTime)
    }

    func testDTO_FromSession_HandlesNilGoal() {
        // Given: A session without a goal
        let session = FastingSession(startTime: Date(), goalMinutes: nil)

        // When: Creating a DTO
        let dto = FastingSessionDTO(from: session)

        // Then: Goal should be nil
        XCTAssertNil(dto.goalMinutes)
    }

    // MARK: - Session from DTO Tests

    func testSession_FromDTO_RestoresAllProperties() {
        // Given: A DTO with all properties
        let originalSession = FastingSession(
            startTime: Date().addingTimeInterval(-7200),
            goalMinutes: 480
        )
        originalSession.endTime = Date().addingTimeInterval(-3600)
        originalSession.goalCelebrationShown = true
        let dto = FastingSessionDTO(from: originalSession)

        // When: Creating a session from the DTO
        let restoredSession = FastingSession(from: dto)

        // Then: All properties should be restored
        XCTAssertEqual(restoredSession.id, dto.id)
        XCTAssertEqual(restoredSession.startTime, dto.startTime)
        XCTAssertEqual(restoredSession.endTime, dto.endTime)
        XCTAssertEqual(restoredSession.goalMinutes, dto.goalMinutes)
        XCTAssertEqual(restoredSession.goalCelebrationShown, dto.goalCelebrationShown)
    }

    func testSession_FromDTO_RestoresNilValues() {
        // Given: A DTO with nil optional values
        let originalSession = FastingSession(startTime: Date(), goalMinutes: nil)
        let dto = FastingSessionDTO(from: originalSession)

        // When: Creating a session from the DTO
        let restoredSession = FastingSession(from: dto)

        // Then: Nil values should be preserved
        XCTAssertNil(restoredSession.endTime)
        XCTAssertNil(restoredSession.goalMinutes)
    }

    // MARK: - toDTO Extension Tests

    func testToDTO_ReturnsEquivalentDTO() {
        // Given: A session
        let session = FastingSession(goalMinutes: 720)
        session.endTime = Date()

        // When: Using the toDTO() convenience method
        let dto = session.toDTO()

        // Then: Should match direct DTO creation
        let directDTO = FastingSessionDTO(from: session)
        XCTAssertEqual(dto.id, directDTO.id)
        XCTAssertEqual(dto.startTime, directDTO.startTime)
        XCTAssertEqual(dto.endTime, directDTO.endTime)
        XCTAssertEqual(dto.goalMinutes, directDTO.goalMinutes)
    }

    // MARK: - Round Trip Tests

    func testRoundTrip_SessionToDTO_AndBack() {
        // Given: An original session
        let original = FastingSession(
            startTime: Date().addingTimeInterval(-57600),
            goalMinutes: 960
        )
        original.endTime = Date()
        original.goalCelebrationShown = true

        // When: Converting to DTO and back
        let dto = original.toDTO()
        let restored = FastingSession(from: dto)

        // Then: Restored session should match original
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.startTime, original.startTime)
        XCTAssertEqual(restored.endTime, original.endTime)
        XCTAssertEqual(restored.goalMinutes, original.goalMinutes)
        XCTAssertEqual(restored.goalCelebrationShown, original.goalCelebrationShown)
        XCTAssertEqual(restored.isActive, original.isActive)
        XCTAssertEqual(restored.goalMet, original.goalMet)
    }

    func testRoundTrip_ActiveSession() {
        // Given: An active session (no end time)
        let original = FastingSession(
            startTime: Date().addingTimeInterval(-3600),
            goalMinutes: 960
        )

        // When: Converting to DTO and back
        let restored = FastingSession(from: original.toDTO())

        // Then: Session should still be active
        XCTAssertTrue(restored.isActive)
        XCTAssertNil(restored.endTime)
    }
}

// MARK: - DataSnapshot Tests

final class DataSnapshotTests: XCTestCase {

    func testDataSnapshot_Initialization_SetsVersionAndDate() {
        // Given: Some session DTOs
        let session = FastingSession(goalMinutes: 960)
        let dtos = [FastingSessionDTO(from: session)]

        // When: Creating a snapshot
        let snapshot = DataSnapshot(sessions: dtos)

        // Then: Version and date should be set
        XCTAssertEqual(snapshot.version, 1)
        XCTAssertEqual(snapshot.sessions.count, 1)
        // Export date should be recent (within last second)
        XCTAssertLessThan(abs(snapshot.exportDate.timeIntervalSinceNow), 1.0)
    }

    func testDataSnapshot_WithEmptySessions() {
        // Given: No sessions
        let dtos: [FastingSessionDTO] = []

        // When: Creating a snapshot
        let snapshot = DataSnapshot(sessions: dtos)

        // Then: Should handle empty array
        XCTAssertEqual(snapshot.sessions.count, 0)
        XCTAssertEqual(snapshot.version, 1)
    }

    func testDataSnapshot_WithMultipleSessions() {
        // Given: Multiple sessions
        let sessions = [
            FastingSession(startTime: Date().addingTimeInterval(-86400), goalMinutes: 960),
            FastingSession(startTime: Date().addingTimeInterval(-172800), goalMinutes: 480),
            FastingSession(startTime: Date().addingTimeInterval(-259200), goalMinutes: 720)
        ]
        sessions.forEach { $0.stop() }
        let dtos = sessions.map { $0.toDTO() }

        // When: Creating a snapshot
        let snapshot = DataSnapshot(sessions: dtos)

        // Then: All sessions should be included
        XCTAssertEqual(snapshot.sessions.count, 3)
    }
}

// MARK: - JSON Encoding/Decoding Tests

final class DTOCodableTests: XCTestCase {

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func testFastingSessionDTO_EncodesAndDecodes() throws {
        // Given: A DTO
        let original = FastingSession(
            startTime: Date().addingTimeInterval(-3600),
            goalMinutes: 960
        )
        original.endTime = Date()
        let dto = original.toDTO()

        // When: Encoding and decoding
        let data = try encoder.encode(dto)
        let decoded = try decoder.decode(FastingSessionDTO.self, from: data)

        // Then: Decoded DTO should match original
        XCTAssertEqual(decoded.id, dto.id)
        XCTAssertEqual(decoded.goalMinutes, dto.goalMinutes)
        XCTAssertEqual(decoded.goalCelebrationShown, dto.goalCelebrationShown)
        // Dates may have slight precision differences with ISO8601
        XCTAssertEqual(decoded.startTime.timeIntervalSince1970, dto.startTime.timeIntervalSince1970, accuracy: 1.0)
    }

    func testDataSnapshot_EncodesAndDecodes() throws {
        // Given: A snapshot with sessions
        let sessions = [
            FastingSession(goalMinutes: 960),
            FastingSession(goalMinutes: 480)
        ]
        let dtos = sessions.map { $0.toDTO() }
        let snapshot = DataSnapshot(sessions: dtos)

        // When: Encoding and decoding
        let data = try encoder.encode(snapshot)
        let decoded = try decoder.decode(DataSnapshot.self, from: data)

        // Then: Decoded snapshot should match
        XCTAssertEqual(decoded.version, snapshot.version)
        XCTAssertEqual(decoded.sessions.count, snapshot.sessions.count)
    }

    func testDTO_WithNilValues_EncodesCorrectly() throws {
        // Given: A DTO with nil values
        let session = FastingSession(startTime: Date(), goalMinutes: nil)
        let dto = session.toDTO()

        // When: Encoding
        let data = try encoder.encode(dto)
        let jsonString = String(data: data, encoding: .utf8)!

        // Then: Should encode without error and contain null for optional fields
        XCTAssertTrue(jsonString.contains("\"endTime\":null") || !jsonString.contains("\"endTime\""))
    }
}
