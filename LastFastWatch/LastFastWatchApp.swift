// LastFastWatchApp.swift
// LastFastWatch
// watchOS Companion App

import SwiftUI
import SwiftData

@main
struct LastFastWatchApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([FastingSession.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.dev.stringer.lastfast.shared")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
