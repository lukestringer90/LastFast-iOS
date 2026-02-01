//
//  HistoryButton.swift
//  LastFast
//
//  Secondary button for navigating to history view
//

import SwiftUI

struct HistoryButton: View {
    var lastFastDuration: TimeInterval?
    var onTap: () -> Void

    private var formattedDuration: String {
        guard let duration = lastFastDuration else { return "" }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                if lastFastDuration != nil {
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .medium))
                    Text(formattedDuration)
                        .font(.system(size: 16, weight: .semibold))
                } else {
                    Text("Fasting History")
                        .font(.system(size: 16, weight: .semibold))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.blue)
        }
    }
}

// MARK: - Preview

#Preview("With Last Fast") {
    HistoryButton(lastFastDuration: 16.5 * 3600, onTap: {})
}

#Preview("No History") {
    HistoryButton(lastFastDuration: nil, onTap: {})
}
