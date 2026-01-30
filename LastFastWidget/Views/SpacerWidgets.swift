//
//  SpacerWidgets.swift
//  LastFastWidget
//
//  Spacer widgets for Lock Screen layout
//

import SwiftUI
import WidgetKit

// MARK: - Spacer Entry

struct SpacerEntry: TimelineEntry {
    let date: Date
}

// MARK: - Spacer Timeline Provider

struct SpacerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpacerEntry {
        SpacerEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SpacerEntry) -> Void) {
        completion(SpacerEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SpacerEntry>) -> Void) {
        let entry = SpacerEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - Spacer Widget View

struct SpacerWidgetView: View {
    var body: some View {
        Color.clear
            .containerBackground(for: .widget) { }
    }
}

// MARK: - Circular Spacer Widget

struct SpacerWidget: Widget {
    let kind: String = "SpacerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpacerTimelineProvider()) { _ in
            SpacerWidgetView()
        }
        .configurationDisplayName("Spacer")
        .description("A blank widget to use as a spacer on the Lock Screen.")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Rectangular Spacer Widget

struct RectangularSpacerWidget: Widget {
    let kind: String = "RectangularSpacerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpacerTimelineProvider()) { _ in
            SpacerWidgetView()
        }
        .configurationDisplayName("Spacer (Medium)")
        .description("A blank medium-width widget to use as a spacer on the Lock Screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}
