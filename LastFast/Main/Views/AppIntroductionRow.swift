//
//  AppIntroductionRow.swift
//  LastFast
//
//  Reusable row for the "View App Introduction" settings entry
//

import SwiftUI

struct AppIntroductionRow: View {
    var action: (() -> Void)? = nil

    var body: some View {
        let content = HStack(spacing: 12) {
            Image(systemName: "hand.wave")
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text("View App Introduction")
                Text("Replay the introduction to Last Fast")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }

        if let action {
            Button(action: action) { content }
                .tint(.primary)
        } else {
            content
        }
    }
}

#Preview("Button") {
    List {
        AppIntroductionRow(action: {})
    }
}

#Preview("Static") {
    AppIntroductionRow()
        .padding()
}
