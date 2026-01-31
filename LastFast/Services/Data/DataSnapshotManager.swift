//
//  DataSnapshotManager.swift
//  LastFast
//
//  Manages export and import of SwiftData snapshots for testing
//

import Foundation
import SwiftData

#if DEBUG

// MARK: - Snapshot Errors

enum SnapshotError: LocalizedError {
    case seedFileNotFound(String)
    case exportDirectoryCreationFailed
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .seedFileNotFound(let name):
            return "Seed file '\(name).json' not found in bundle"
        case .exportDirectoryCreationFailed:
            return "Failed to create snapshots directory"
        case .encodingFailed:
            return "Failed to encode data to JSON"
        case .decodingFailed:
            return "Failed to decode JSON data"
        }
    }
}

// MARK: - Data Snapshot Manager

class DataSnapshotManager {
    static let shared = DataSnapshotManager()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init() {}

    // MARK: - Export

    /// Export all sessions to a JSON file in the Documents directory
    /// - Parameter context: The ModelContext to export from
    /// - Returns: URL of the exported file
    func exportSnapshot(from context: ModelContext) throws -> URL {
        let descriptor = FetchDescriptor<FastingSession>(
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        let sessions = try context.fetch(descriptor)

        let dtos = sessions.map { $0.toDTO() }
        let snapshot = DataSnapshot(sessions: dtos)

        guard let jsonData = try? encoder.encode(snapshot) else {
            throw SnapshotError.encodingFailed
        }

        let snapshotsDir = try getSnapshotsDirectory()
        let timestamp = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let filename = "snapshot_\(timestamp).json"
        let fileURL = snapshotsDir.appendingPathComponent(filename)

        try jsonData.write(to: fileURL)

        print("📸 Snapshot exported: \(fileURL.path)")
        print("   Sessions: \(sessions.count)")

        return fileURL
    }

    // MARK: - Import

    /// Import sessions from JSON data, clearing existing data first
    /// - Parameters:
    ///   - data: JSON data to import
    ///   - context: The ModelContext to import into
    func importSnapshot(_ data: Data, into context: ModelContext) throws {
        guard let snapshot = try? decoder.decode(DataSnapshot.self, from: data) else {
            throw SnapshotError.decodingFailed
        }

        // Clear existing data
        try clearAllData(in: context)

        // Import new sessions
        for dto in snapshot.sessions {
            let session = FastingSession(from: dto)
            context.insert(session)
        }

        try context.save()

        print("📥 Snapshot imported:")
        print("   Version: \(snapshot.version)")
        print("   Sessions: \(snapshot.sessions.count)")
    }

    // MARK: - Seed Data

    /// Load seed data from the application bundle
    /// - Parameters:
    ///   - filename: Name of the JSON file (without extension)
    ///   - context: The ModelContext to seed
    func loadSeedData(named filename: String, into context: ModelContext) throws {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw SnapshotError.seedFileNotFound(filename)
        }

        let data = try Data(contentsOf: url)
        try importSnapshot(data, into: context)

        print("🌱 Seeded from: \(filename).json")
    }

    // MARK: - Clear Data

    /// Delete all FastingSession records
    /// - Parameter context: The ModelContext to clear
    func clearAllData(in context: ModelContext) throws {
        let descriptor = FetchDescriptor<FastingSession>()
        let sessions = try context.fetch(descriptor)

        for session in sessions {
            context.delete(session)
        }

        try context.save()

        print("🗑️ Cleared \(sessions.count) sessions")
    }

    // MARK: - Helpers

    private func getSnapshotsDirectory() throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let snapshotsURL = documentsURL.appendingPathComponent("snapshots")

        if !FileManager.default.fileExists(atPath: snapshotsURL.path) {
            do {
                try FileManager.default.createDirectory(at: snapshotsURL, withIntermediateDirectories: true)
            } catch {
                throw SnapshotError.exportDirectoryCreationFailed
            }
        }

        return snapshotsURL
    }
}

// MARK: - Launch Argument Handling

extension DataSnapshotManager {
    /// Process launch arguments for data seeding/export
    /// Call this from your App's init or onAppear
    func handleLaunchArguments(context: ModelContext) {
        let args = ProcessInfo.processInfo.arguments

        // Handle --clear-data first
        if args.contains("--clear-data") {
            try? clearAllData(in: context)
        }

        // Handle --seed-data <filename>
        if let seedIndex = args.firstIndex(of: "--seed-data"),
           seedIndex + 1 < args.count {
            let filename = args[seedIndex + 1]
            do {
                try loadSeedData(named: filename, into: context)
            } catch {
                print("❌ Seed failed: \(error.localizedDescription)")
            }
        }

        // Handle --export-snapshot
        if args.contains("--export-snapshot") {
            do {
                let url = try exportSnapshot(from: context)
                print("📸 Export complete: \(url.path)")
            } catch {
                print("❌ Export failed: \(error.localizedDescription)")
            }
        }
    }
}

#endif
