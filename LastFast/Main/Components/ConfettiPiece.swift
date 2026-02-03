//
//  ConfettiPiece.swift
//  LastFast
//
//  Data model for a single confetti piece in the celebration animation
//

import SwiftUI

// MARK: - Confetti Piece

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let rotation: Double
    let scale: CGFloat
    let isCircle: Bool
}
