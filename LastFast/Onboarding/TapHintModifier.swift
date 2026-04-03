// TapHintModifier.swift
// LastFast
//
// Overlays an animated hand.tap.fill indicator on tappable onboarding mockups

import SwiftUI

struct TapHintModifier: ViewModifier {
    @State private var phase: Phase = .offScreen

    private enum Phase { case offScreen, onScreen, tapping }

    private var handOpacity: Double {
        switch phase {
        case .offScreen: 0
        case .onScreen: 0.45
        case .tapping: 0.65
        }
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content

            Image(systemName: "hand.tap.fill")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .opacity(handOpacity)
                .scaleEffect(phase == .tapping ? 0.82 : 1.0)
                .offset(
                    x: phase == .offScreen ? 30 : 0,
                    y: phase == .offScreen ? 30 : 0
                )
                .padding(4)
        }
        .task {
            while !Task.isCancelled {
                // Pause off-screen
                try? await Task.sleep(for: .seconds(0.8))
                // Slide in
                withAnimation(.easeOut(duration: 0.35)) { phase = .onScreen }
                try? await Task.sleep(for: .seconds(0.55))
                // Tap down
                withAnimation(.easeIn(duration: 0.1)) { phase = .tapping }
                try? await Task.sleep(for: .seconds(0.2))
                // Spring release
                withAnimation(.spring(duration: 0.4, bounce: 0.4)) { phase = .onScreen }
                try? await Task.sleep(for: .seconds(0.5))
                // Slide out
                withAnimation(.easeIn(duration: 0.25)) { phase = .offScreen }
                try? await Task.sleep(for: .seconds(0.25))
            }
        }
    }
}

extension View {
    func tapHint() -> some View {
        modifier(TapHintModifier())
    }
}
