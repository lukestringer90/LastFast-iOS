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
        let content = Label {
            VStack(alignment: .leading, spacing: 2) {
                Text("View App Introduction")
                Text("Replay the introduction to Last Fast")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: "hand.wave.fill")
                .foregroundStyle(.blue)
                .font(.body)
                .imageScale(.large)
        }
        .labelStyle(.centerAligned)

        if let action {
            Button(action: action) { content }
                .tint(.primary)
        } else {
            content
        }
    }
}

private struct CenterAlignedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 12) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == CenterAlignedLabelStyle {
    static var centerAligned: CenterAlignedLabelStyle { CenterAlignedLabelStyle() }
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
