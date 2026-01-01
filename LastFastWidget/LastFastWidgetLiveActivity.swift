//
//  LastFastWidgetLiveActivity.swift
//  LastFastWidget
//
//  Created by Luke Stringer on 31/12/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LastFastWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LastFastWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LastFastWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LastFastWidgetAttributes {
    fileprivate static var preview: LastFastWidgetAttributes {
        LastFastWidgetAttributes(name: "World")
    }
}

extension LastFastWidgetAttributes.ContentState {
    fileprivate static var smiley: LastFastWidgetAttributes.ContentState {
        LastFastWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LastFastWidgetAttributes.ContentState {
         LastFastWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LastFastWidgetAttributes.preview) {
   LastFastWidgetLiveActivity()
} contentStates: {
    LastFastWidgetAttributes.ContentState.smiley
    LastFastWidgetAttributes.ContentState.starEyes
}
