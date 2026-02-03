//
//  SessionCard.swift
//  LastFast
//
//  Unified card view for displaying a fasting session
//

import SwiftUI

struct SessionCard: View {
    let session: FastingSession
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var showBackground: Bool = false

    @State private var offset: CGFloat = 0
    @State private var showingActions = false
    @State private var showingEditSheet = false


    var body: some View {
        ZStack(alignment: .trailing) {
            if showBackground {
                swipeActions
            }

            cardContent
                .background(background)
                .offset(x: showBackground ? offset : 0)
                .gesture(showBackground ? swipeGesture : nil)
        }
        .clipped()
        .sheet(isPresented: $showingEditSheet) {
            EditFastView(session: session)
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDuration(from: session.duration))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(GoalStatusColors.durationColor(goalMet: session.goalMet, hasGoal: session.goalMinutes != nil))

                Text(session.startTime.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                TimeRangeLabel(startTime: session.startTime, endTime: session.endTime)

                if let goal = session.goalMinutes {
                    Text("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(showBackground ? 16 : 8)
    }


    @ViewBuilder
    private var background: some View {
        if showBackground {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        }
    }

    // MARK: - Swipe Actions

    private var swipeActions: some View {
        HStack(spacing: 8) {
            Spacer()
            Button {
                withAnimation { offset = 0 }
                if let onEdit {
                    onEdit()
                } else {
                    showingEditSheet = true
                }
            } label: {
                Image(systemName: "pencil")
                    .font(.title3)
                    .frame(width: 56, height: 56)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            Button {
                withAnimation { offset = 0 }
                onDelete?()
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
                    .frame(width: 56, height: 56)
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.width < 0 {
                    offset = max(value.translation.width, -120)
                } else if showingActions {
                    offset = min(0, -120 + value.translation.width)
                }
            }
            .onEnded { value in
                withAnimation(.spring(response: 0.3)) {
                    if value.translation.width < -60 {
                        offset = -120
                        showingActions = true
                    } else {
                        offset = 0
                        showingActions = false
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("In List") {
    List {
        SessionCard(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-57600),
                goalMinutes: defaultFastingGoalMinutes
            )
            session.endTime = Date()
            return session
        }())

        SessionCard(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-7200),
                goalMinutes: defaultFastingGoalMinutes
            )
            session.endTime = Date()
            return session
        }())

        SessionCard(session: {
            let session = FastingSession(
                startTime: Date().addingTimeInterval(-28800)
            )
            session.endTime = Date()
            return session
        }())
    }
}

#Preview("Standalone Card") {
    VStack {
        SessionCard(
            session: {
                let session = FastingSession(
                    startTime: Date().addingTimeInterval(-57600),
                    goalMinutes: defaultFastingGoalMinutes
                )
                session.endTime = Date()
                return session
            }(),
            showBackground: true
        )

        SessionCard(
            session: {
                let session = FastingSession(
                    startTime: Date().addingTimeInterval(-7200),
                    goalMinutes: defaultFastingGoalMinutes
                )
                session.endTime = Date()
                return session
            }(),
            showBackground: true
        )
    }
    .padding()
}
