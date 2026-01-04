//
//  RectangularWidgets.swift
//  LastFastWidget
//
//  Rectangular Lock Screen widget configurations
//

import SwiftUI
import WidgetKit

// MARK: - Rectangular Combined Widget (Left-Aligned)

struct RectangularCombinedWidget: Widget {
    let kind: String = "RectangularCombinedWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time")
        .description("A rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Rectangular Combined Widget (Right-Aligned)

struct RectangularCombinedRightWidget: Widget {
    let kind: String = "RectangularCombinedRightWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedRightView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time (Right)")
        .description("A right-aligned rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Rectangular Combined Widget (Center-Aligned)

struct RectangularCombinedCenterWidget: Widget {
    let kind: String = "RectangularCombinedCenterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedCenterView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time (Center)")
        .description("A center-aligned rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}
