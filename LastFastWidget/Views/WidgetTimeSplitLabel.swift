//
//  WidgetTimeSplitLabel.swift
//  LastFastWidget
//
//  Displays a formatted time. When the locale uses AM/PM, wraps the period
//  onto a second line so short formats ("14:55") stay on one line while longer
//  ones ("2:55 PM") stack neatly.
//

import SwiftUI

struct WidgetTimeSplitLabel: View {
    let date: Date
    let size: CGFloat
    let weight: Font.Weight

    private var parts: (time: String, period: String?) {
        let periodFormatter = DateFormatter()
        periodFormatter.dateFormat = "a"
        let period = periodFormatter.string(from: date)

        let full = formatTime(date)

        guard full.localizedCaseInsensitiveContains(period) else {
            return (full, nil)
        }

        let timePart = full
            .replacingOccurrences(of: period, with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        return (timePart, period)
    }

    var body: some View {
        Group {
            if let period = parts.period {
                Text(parts.time + "\n" + period)
                    .multilineTextAlignment(.center)
            } else {
                Text(parts.time).multilineTextAlignment(.center)
            }
        }
        .font(.system(size: size, weight: weight, design: .rounded))
    }
}
