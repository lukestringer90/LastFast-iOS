//
//  FastingSessionDTO.swift
//  LastFast
//
//  Data Transfer Object for JSON serialization of FastingSession
//

import Foundation

// MARK: - Data Snapshot

/// Container for exported data with version info
struct DataSnapshot: Codable {
    let version: Int
    let exportDate: Date
    let sessions: [FastingSessionDTO]

    init(sessions: [FastingSessionDTO]) {
        self.version = 1
        self.exportDate = Date()
        self.sessions = sessions
    }
}

// MARK: - Fasting Session DTO

/// Codable representation of FastingSession for JSON export/import
struct FastingSessionDTO: Codable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let goalMinutes: Int?
    let goalCelebrationShown: Bool

    init(from session: FastingSession) {
        self.id = session.id
        self.startTime = session.startTime
        self.endTime = session.endTime
        self.goalMinutes = session.goalMinutes
        self.goalCelebrationShown = session.goalCelebrationShown
    }
}

// MARK: - FastingSession Extension

extension FastingSession {
    /// Create a FastingSession from a DTO
    convenience init(from dto: FastingSessionDTO) {
        self.init(startTime: dto.startTime, goalMinutes: dto.goalMinutes)
        self.id = dto.id
        self.endTime = dto.endTime
        self.goalCelebrationShown = dto.goalCelebrationShown
    }

    /// Convert to DTO for serialization
    func toDTO() -> FastingSessionDTO {
        FastingSessionDTO(from: self)
    }
}
