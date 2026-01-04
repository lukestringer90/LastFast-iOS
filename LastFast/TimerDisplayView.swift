//
//  TimerDisplayView.swift
//  LastFast
//
//  View for displaying the main countdown/elapsed timer
//

import SwiftUI

// MARK: - Timer Display View

struct TimerDisplayView: View {
    let goalMet: Bool
    let hours: Int
    let minutes: Int
    let elapsedHours: Int
    let elapsedMins: Int
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            headerText
            timeDisplay
            
            if !goalMet {
                progressBar
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Header
    
    private var headerText: some View {
        Text(goalMet ? "You've fasted for" : "Keep fasting")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }
    
    // MARK: - Time Display
    
    @ViewBuilder
    private var timeDisplay: some View {
        if goalMet {
            elapsedTimeDisplay
        } else if hours > 0 {
            hoursAndMinutesDisplay
        } else {
            minutesOnlyDisplay
        }
    }
    
    private var elapsedTimeDisplay: some View {
        Group {
            if elapsedHours > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(elapsedHours)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    
                    Text("h")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                    
                    Text("\(elapsedMins)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    
                    Text("m")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(elapsedMins)")
                        .font(.system(size: 110, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    
                    Text("m")
                        .font(.system(size: 33, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                }
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
        }
    }
    
    private var hoursAndMinutesDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(hours)")
                .font(.system(size: 110, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
            
            Text("h")
                .font(.system(size: 33, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))
            
            Text("\(minutes)")
                .font(.system(size: 110, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
            
            Text("m")
                .font(.system(size: 33, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
    
    private var minutesOnlyDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(minutes)")
                .font(.system(size: 110, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
            
            Text("m")
                .font(.system(size: 33, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(height: 16)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange)
                    .frame(width: geometry.size.width * progress, height: 16)
            }
        }
        .frame(height: 16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        TimerDisplayView(
            goalMet: false,
            hours: 8,
            minutes: 30,
            elapsedHours: 7,
            elapsedMins: 30,
            progress: 0.47
        )
        
        TimerDisplayView(
            goalMet: true,
            hours: 0,
            minutes: 0,
            elapsedHours: 16,
            elapsedMins: 5,
            progress: 1.0
        )
    }
}
