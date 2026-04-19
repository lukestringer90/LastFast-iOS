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

    // Custom decoding to support relative timestamps (e.g., "RELATIVE:-9.6h")
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        goalMinutes = try container.decodeIfPresent(Int.self, forKey: .goalMinutes)
        goalCelebrationShown = try container.decodeIfPresent(Bool.self, forKey: .goalCelebrationShown) ?? false

        // Decode startTime (supports relative or absolute)
        startTime = try Self.decodeDate(from: container, forKey: .startTime)

        // Decode endTime (optional, supports relative or absolute)
        if container.contains(.endTime) {
            endTime = try Self.decodeDateIfPresent(from: container, forKey: .endTime)
        } else {
            endTime = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, goalMinutes, goalCelebrationShown
    }

    private static func decodeDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date {
        // Try decoding as string first (for relative timestamps)
        if let stringValue = try? container.decode(String.self, forKey: key) {
            if let date = parseRelativeOrAbsoluteDate(stringValue) {
                return date
            }
        }
        // Fall back to standard Date decoding
        return try container.decode(Date.self, forKey: key)
    }

    private static func decodeDateIfPresent(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) throws -> Date? {
        // Try decoding as string first (for relative timestamps)
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            if stringValue.isEmpty || stringValue == "null" {
                return nil
            }
            return parseRelativeOrAbsoluteDate(stringValue)
        }
        // Fall back to standard Date decoding
        return try container.decodeIfPresent(Date.self, forKey: key)
    }

    /// Parse a date string that may be relative (e.g., "RELATIVE:-9.6h") or absolute ISO8601
    private static func parseRelativeOrAbsoluteDate(_ string: String) -> Date? {
        if string.hasPrefix("RELATIVE:") {
            return parseRelativeTime(String(string.dropFirst(9)))
        }
        // Try ISO8601 parsing
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: string) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }

    /// Parse relative time string like "-9.6h", "-1d", "-1d-17h"
    private static func parseRelativeTime(_ string: String) -> Date? {
        var totalSeconds: TimeInterval = 0
        let current = string

        // Pattern: optional minus, number (with optional decimal), unit (d/h/m/s)
        let pattern = #"(-?\d+\.?\d*)([dhms])"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }

        let range = NSRange(current.startIndex..., in: current)
        let matches = regex.matches(in: current, range: range)

        for match in matches {
            guard let valueRange = Range(match.range(at: 1), in: current),
                  let unitRange = Range(match.range(at: 2), in: current),
                  let value = Double(current[valueRange]) else {
                continue
            }
            let unit = String(current[unitRange])
            let multiplier: TimeInterval = switch unit {
                case "d": 86400
                case "h": 3600
                case "m": 60
                case "s": 1
                default: 0
            }
            totalSeconds += value * multiplier
        }

        return Date().addingTimeInterval(totalSeconds)
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
