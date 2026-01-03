//
//  LastFastWidgetLiveActivity.swift
//  LastFastWidget
//
//  Live Activity for tracking fasting progress
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

struct LastFastWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LastFastWidgetAttributes.self) { context in
            // Lock screen/banner UI
            let endTime = context.attributes.startTime.addingTimeInterval(TimeInterval(context.attributes.goalMinutes * 60))
            let startTime = context.attributes.startTime
            let remainingSeconds = max(0, Int(endTime.timeIntervalSince(Date())))
            let remainingHours = remainingSeconds / 3600
            let remainingMins = (remainingSeconds % 3600) / 60
            let elapsedSeconds = context.state.elapsedSeconds
            let elapsedHours = elapsedSeconds / 3600
            let elapsedMins = (elapsedSeconds % 3600) / 60
            
            if context.state.goalMet {
                // GOAL MET: Simplified view with elapsed time and checkmark
                HStack {
                    // Left side - Total elapsed time
                    Text("\(elapsedHours)h \(elapsedMins)m")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    // Right side - Green checkmark
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.green)
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
            } else {
                // IN PROGRESS: Full view with countdown, end time, and progress bar
                VStack(spacing: 12) {
                    HStack(alignment: .top) {
                        // Left side - TIME REMAINING
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fasted for \(elapsedHours)h \(elapsedMins)m")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(remainingHours)h \(remainingMins)m")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        // Right side - END TIME
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(format24HourTime(startTime)) to")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(format24HourTime(endTime))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                    }
                    
                    // Progress bar
                    let progress = min(1.0, Double(context.state.elapsedSeconds) / Double(context.attributes.goalMinutes * 60))
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemBackground))
            }
            
        } dynamicIsland: { context in
            let endTime = context.attributes.startTime.addingTimeInterval(TimeInterval(context.attributes.goalMinutes * 60))
            let remainingSeconds = max(0, Int(endTime.timeIntervalSince(Date())))
            let remainingHours = remainingSeconds / 3600
            let remainingMins = (remainingSeconds % 3600) / 60
            let elapsedSeconds = context.state.elapsedSeconds
            let elapsedHours = elapsedSeconds / 3600
            let elapsedMins = (elapsedSeconds % 3600) / 60
            
            return DynamicIsland {
                // EXPANDED VIEW
                DynamicIslandExpandedRegion(.leading) {
                    if context.state.goalMet {
                        Text("\(elapsedHours)h \(elapsedMins)m")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    } else {
                        Text("\(remainingHours)h \(remainingMins)m")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.goalMet {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    } else {
                        Text(format24HourTime(endTime))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if !context.state.goalMet {
                        let progress = min(1.0, Double(context.state.elapsedSeconds) / Double(context.attributes.goalMinutes * 60))
                        ProgressView(value: progress)
                            .tint(.orange)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
            } compactLeading: {
                // COMPACT VIEW - Left side
                if context.state.goalMet {
                    Text("\(elapsedHours)h\(elapsedMins)m")
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                } else {
                    Text("\(remainingHours)h\(remainingMins)m")
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                }
            } compactTrailing: {
                // COMPACT VIEW - Right side
                if context.state.goalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text(format24HourTime(endTime))
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            } minimal: {
                if context.state.goalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text("\(remainingHours)h")
                        .font(.system(size: 9))
                }
            }
            .contentMargins(.leading, 20, for: .expanded)
            .contentMargins(.trailing, 20, for: .expanded)
            .contentMargins(.bottom, 12, for: .expanded)
        }
    }
}

// MARK: - Previews

extension LastFastWidgetAttributes {
    fileprivate static var preview: LastFastWidgetAttributes {
        LastFastWidgetAttributes(
            startTime: Date().addingTimeInterval(-4 * 3600),
            goalMinutes: 480
        )
    }
}

extension LastFastWidgetAttributes.ContentState {
    fileprivate static var inProgress: LastFastWidgetAttributes.ContentState {
        LastFastWidgetAttributes.ContentState(
            elapsedSeconds: 4 * 3600,
            goalMet: false
        )
    }
    
    fileprivate static var goalReached: LastFastWidgetAttributes.ContentState {
        LastFastWidgetAttributes.ContentState(
            elapsedSeconds: 9 * 3600,
            goalMet: true
        )
    }
}

#Preview("Notification - In Progress", as: .content, using: LastFastWidgetAttributes.preview) {
    LastFastWidgetLiveActivity()
} contentStates: {
    LastFastWidgetAttributes.ContentState.inProgress
}

#Preview("Notification - Goal Reached", as: .content, using: LastFastWidgetAttributes.preview) {
    LastFastWidgetLiveActivity()
} contentStates: {
    LastFastWidgetAttributes.ContentState.goalReached
}
