//
//  HistoryButton.swift
//  LastFast
//
//  Secondary button for navigating to history view
//

import SwiftUI

struct HistoryButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.subheadline)
                Text("History")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryButton(onTap: {})
}
