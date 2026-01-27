//
//  ConfettiView.swift
//  LastFast
//
//  Confetti celebration animation for goal completion
//

import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
    let isCircle: Bool
}

struct ConfettiView: View {
    @Binding var isShowing: Bool

    @State private var pieces: [ConfettiPiece] = []
    @State private var animationProgress: CGFloat = 0

    private let colors: [Color] = [
        .green, .mint, .teal, .cyan,
        Color(red: 0.2, green: 0.8, blue: 0.4),
        Color(red: 0.4, green: 0.9, blue: 0.5),
        Color(red: 0.3, green: 0.7, blue: 0.6)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isCircle {
                            Circle()
                                .fill(piece.color)
                                .frame(width: 10 * piece.scale, height: 10 * piece.scale)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(piece.color)
                                .frame(width: 8 * piece.scale, height: 16 * piece.scale)
                        }
                    }
                    .rotationEffect(.degrees(piece.rotation + Double(animationProgress) * 360))
                    .position(
                        x: piece.x + sin(Double(animationProgress) * .pi * 4 + piece.rotation) * 30,
                        y: piece.y + animationProgress * (geometry.size.height + 100)
                    )
                    .opacity(animationProgress < 0.8 ? 1 : 1 - (animationProgress - 0.8) / 0.2)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            startConfetti()
        }
    }

    private func startConfetti() {
        pieces = (0..<60).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: -100...(-20)),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.6...1.4),
                isCircle: Bool.random()
            )
        }

        withAnimation(.easeOut(duration: 3.0)) {
            animationProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isShowing = false
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.1)
        ConfettiView(isShowing: .constant(true))
    }
}
