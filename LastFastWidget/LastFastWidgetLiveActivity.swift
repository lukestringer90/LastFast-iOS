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
            // Lock screen/banner UI - expanded view like Uber
            VStack(alignment: .leading, spacing: 12) {
                // Top row - app name and status
                HStack {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("Last Fast")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    if context.state.goalMet {
                        Text("GOAL MET")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    } else {
                        Text("FASTING")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                // Middle row - main time display
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Elapsed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        let hours = context.state.elapsedSeconds / 3600
                        let mins = (context.state.elapsedSeconds % 3600) / 60
                        
                        Text("\(hours)h \(mins)m")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(context.state.goalMet ? .green : .primary)
                    }
                    
                    Spacer()
                    
                    if !context.state.goalMet {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("End time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            let endTime = context.attributes.startTime.addingTimeInterval(TimeInterval(context.attributes.goalMinutes * 60))
                            Text(format24HourTime(endTime))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.green)
                    }
                }
                
                // Bottom row - progress
                if !context.state.goalMet {
                    VStack(spacing: 6) {
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
                        
                        HStack {
                            Text(format24HourTime(context.attributes.startTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            let endTime = context.attributes.startTime.addingTimeInterval(TimeInterval(context.attributes.goalMinutes * 60))
                            Text(format24HourTime(endTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            
        } dynamicIsland: { context in
            let remainingSeconds = max(0, (context.attributes.goalMinutes * 60) - context.state.elapsedSeconds)
            let remainingHours = remainingSeconds / 3600
            let remainingMins = (remainingSeconds % 3600) / 60
            let endTime = context.attributes.startTime.addingTimeInterval(TimeInterval(context.attributes.goalMinutes * 60))
            
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(remainingHours)h \(remainingMins)m")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(format24HourTime(endTime))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("remaining until \(format24HourTime(endTime))")
                        .font(.caption)
                }
                DynamicIslandExpandedRegion(.center) {
                    EmptyView()
                }
            } compactLeading: {
                Text("\(remainingHours)h\(remainingMins)m")
            } compactTrailing: {
                Text(format24HourTime(endTime))
            } minimal: {
                Text("\(remainingHours)h")
            }
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
