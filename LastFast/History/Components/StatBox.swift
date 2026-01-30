//
//  StatBox.swift
//  LastFast
//
//  A box view for displaying a statistic with title and value
//

import SwiftUI

struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        StatBox(title: "Total Fasts", value: "12")
        StatBox(title: "Goals Met", value: "8")
        StatBox(title: "Avg Duration", value: "14h 30m")
    }
    .padding()
}
