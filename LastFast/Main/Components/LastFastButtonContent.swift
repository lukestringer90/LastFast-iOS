//
//  LastFastButtonContent.swift
//  LastFast
//
//  Content view for the "Last Fast" button on the main screen
//

import SwiftUI

// MARK: - Last Fast Button Content

struct LastFastButtonContent: View {
    let lastFast: FastingSession?
    
    var body: some View {
        if let last = lastFast {
            lastFastCard(last)
        } else {
            emptyHistoryButton
        }
    }
    
    // MARK: - Last Fast Card
    
    private func lastFastCard(_ session: FastingSession) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Fast")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    let hours = Int(session.duration) / 3600
                    let mins = (Int(session.duration) % 3600) / 60
                    HStack(spacing: 6) {
                        Text(formatDuration(hours: hours, minutes: mins))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(session.goalMet ? .green : .orange)
                        
                        if session.goalMinutes != nil {
                            Image(systemName: session.goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(session.goalMet ? .green : .red)
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        Text("View History")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Empty State
    
    private var emptyHistoryButton: some View {
        HStack(spacing: 8) {
            Image(systemName: "list.bullet.clock")
            Text("View History")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        LastFastButtonContent(lastFast: nil)
        
        LastFastButtonContent(lastFast: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-86400),
                goalMinutes: 720
            )
            session.endTime = Date().addingTimeInterval(-43200)
            return session
        }())
    }
}
