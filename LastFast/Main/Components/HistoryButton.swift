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
            HStack(spacing: 4) {
                Text("Fasting History")
                    .font(.subheadline)
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryButton(onTap: {})
}
