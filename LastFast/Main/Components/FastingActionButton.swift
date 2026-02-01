//
//  FastingActionButton.swift
//  LastFast
//
//  Primary action button for starting/stopping fasts
//

import SwiftUI

struct FastingActionButton: View {
    let isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                Image(systemName: isActive ? "square.fill" : "play.fill")
                    .font(.title2)
                Text(isActive ? "Stop Fast" : "Start Fast")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .frame(height: 60)
            .background(isActive ? Color.red : Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Preview

#Preview("Start") {
    FastingActionButton(isActive: false, onTap: {})
}

#Preview("Stop") {
    FastingActionButton(isActive: true, onTap: {})
}
