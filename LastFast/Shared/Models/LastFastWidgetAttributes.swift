//
//  LastFastWidgetAttributes.swift
//  LastFast
//
//  Live Activity attributes for the fasting widget
//

import Foundation

#if canImport(ActivityKit)
import ActivityKit

// MARK: - Live Activity Attributes

struct LastFastWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state - updated as fast progresses
        var elapsedSeconds: Int
        var goalMet: Bool
    }

    // Fixed properties - set when activity starts
    var startTime: Date
    var goalMinutes: Int
}
#endif
