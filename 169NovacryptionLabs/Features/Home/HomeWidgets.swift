import SwiftUI

// MARK: - Hero

struct HomeHeroWidget: View {
    let greeting: String
    let dateText: String
    let streak: Int
    let minutesToday: Int
    let trainedToday: Bool

    var body: some View {
        AppGlassCard(accentGlow: true) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        Text(dateText)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer()
                    statusBadge
                }

                HStack(spacing: 12) {
                    heroMetric(icon: "flame.fill", title: "Streak", value: "\(streak)", suffix: streak == 1 ? " day" : " days", accent: .appAccent)
                    heroMetric(icon: "clock.fill", title: "Today", value: "\(minutesToday)", suffix: " min", accent: .appPrimary)
                }
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: trainedToday ? "checkmark.seal.fill" : "figure.run")
                .font(.caption.weight(.bold))
            Text(trainedToday ? "Active" : "Ready")
                .font(.caption.weight(.bold))
        }
        .foregroundStyle(trainedToday ? Color.appBackgroundFallback : Color.appTextPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(
                    trainedToday
                        ? LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.appSurfaceFallback.opacity(0.6), Color.appSurfaceFallback.opacity(0.6)], startPoint: .leading, endPoint: .trailing)
                )
        )
    }

    private func heroMetric(icon: String, title: String, value: String, suffix: String, accent: Color) -> some View {
        HStack(spacing: 12) {
            AppIconBadge(systemName: icon, size: 40, tint: accent, background: accent.opacity(0.2))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                Text(value + suffix)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appInsetPanel(cornerRadius: AppDesign.smallRadius)
    }
}

// MARK: - Quick actions

struct HomeQuickActionWidget: View {
    let onTimer: () -> Void
    let onLog: () -> Void
    let onRoutines: () -> Void
    let onProgress: () -> Void

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Quick Actions", subtitle: "Jump into your workout flow")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    actionTile(icon: "timer", title: "Timer", color: .appPrimary, action: onTimer)
                    actionTile(icon: "plus.circle.fill", title: "Log", color: .appAccent, action: onLog)
                    actionTile(icon: "list.bullet.rectangle", title: "Routines", color: .appPrimary, action: onRoutines)
                    actionTile(icon: "chart.bar.fill", title: "Progress", color: .appAccent, action: onProgress)
                }
            }
        }
    }

    private func actionTile(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            VStack(spacing: 10) {
                AppIconBadge(systemName: icon, size: 44, tint: color, background: color.opacity(0.2))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .appInsetPanel(cornerRadius: AppDesign.smallRadius)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Weekly goals

struct HomeGoalsWidget: View {
    let sessionsProgress: Double
    let minutesProgress: Double
    let sessionsText: String
    let minutesText: String

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Weekly Goals", subtitle: "Sessions and minutes")
                AppProgressRow(title: "Sessions", valueText: sessionsText, progress: sessionsProgress)
                AppProgressRow(title: "Minutes", valueText: minutesText, progress: minutesProgress)
            }
        }
    }
}

// MARK: - Week activity

struct HomeWeekActivityWidget: View {
    let days: [(label: String, minutes: Int, isToday: Bool)]

    private var maxMinutes: Int { max(days.map(\.minutes).max() ?? 1, 1) }

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "This Week", subtitle: "Daily minutes")
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: day.isToday
                                            ? [Color.appPrimary, Color.appAccent]
                                            : [Color.appPrimary.opacity(0.5), Color.appAccent.opacity(0.4)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(
                                    height: max(
                                        CGFloat(day.minutes) / CGFloat(maxMinutes) * 72,
                                        day.minutes > 0 ? 8 : 4
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .stroke(day.isToday ? Color.white.opacity(0.35) : Color.clear, lineWidth: 1)
                                )
                            Text(day.label)
                                .font(.caption2.weight(day.isToday ? .bold : .medium))
                                .foregroundStyle(day.isToday ? Color.appAccent : Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 96)
            }
        }
    }
}

// MARK: - Timer snapshot

struct HomeTimerSnapshotWidget: View {
    let workSeconds: Int
    let restSeconds: Int
    let rounds: Int
    let isConfigured: Bool
    let onOpen: () -> Void

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Interval Timer", subtitle: isConfigured ? "Ready to start" : "Not configured yet", actionTitle: "Open", action: onOpen)
                if isConfigured {
                    HStack(spacing: 12) {
                        snapshotPill(icon: "flame.fill", text: "\(workSeconds)s work")
                        snapshotPill(icon: "pause.fill", text: "\(restSeconds)s rest")
                        snapshotPill(icon: "repeat", text: "\(rounds) rounds")
                    }
                } else {
                    Text("Pick a template on the Timer tab to set up your next session.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Button {
                    FeedbackManager.lightTap()
                    onOpen()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(isConfigured ? "Start Timer" : "Configure Timer")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(Color.appBackgroundFallback)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                            .fill(AppGradients.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                                    .fill(AppGradients.topSheen)
                            )
                    )
                    .compositingGroup()
                    .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func snapshotPill(icon: String, text: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.appTextPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.appBackgroundFallback.opacity(0.3))
            .clipShape(Capsule())
    }
}

// MARK: - Routine quick start

struct HomeRoutineQuickStartWidget: View {
    let routines: [ExerciseRoutine]
    let onStart: (ExerciseRoutine) -> Void
    let onSeeAll: () -> Void

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Quick Start", subtitle: "Your routines", actionTitle: routines.count > 2 ? "See All" : nil, action: routines.count > 2 ? onSeeAll : nil)

                if routines.isEmpty {
                    Text("Create a routine in Train to launch guided sessions from here.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                } else {
                    ForEach(routines.prefix(2)) { routine in
                        Button {
                            FeedbackManager.lightTap()
                            onStart(routine)
                        } label: {
                            HStack(spacing: 12) {
                                AppIconBadge(systemName: "figure.strengthtraining.traditional", size: 40)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(routine.title)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text("\(routine.exercises.count) exercises")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.appAccent)
                            }
                            .padding(12)
                            .appInsetPanel(cornerRadius: AppDesign.smallRadius)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Recent sessions

struct HomeRecentSessionsWidget: View {
    let sessions: [WorkoutSessionRecord]
    let onSeeAll: () -> Void
    let onSelect: (WorkoutSessionRecord) -> Void

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(
                    title: "Recent Sessions",
                    subtitle: sessions.isEmpty ? "No sessions yet" : "Last workouts",
                    actionTitle: sessions.isEmpty ? nil : "History",
                    action: sessions.isEmpty ? nil : onSeeAll
                )

                if sessions.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title2)
                            .foregroundStyle(Color.appTextSecondary)
                        Text("Complete a workout to see recent sessions here.")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    ForEach(sessions) { session in
                        Button {
                            FeedbackManager.lightTap()
                            onSelect(session)
                        } label: {
                            HStack(spacing: 12) {
                                AppIconBadge(
                                    systemName: icon(for: session.sessionType),
                                    size: 38,
                                    tint: .appPrimary
                                )
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(session.typeLabel)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(Self.dateFormatter.string(from: session.date))
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Spacer()
                                Text("\(session.minutes) min")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(Color.appAccent)
                            }
                        }
                        .buttonStyle(.plain)
                        if session.id != sessions.last?.id {
                            Divider().overlay(Color.white.opacity(0.1))
                        }
                    }
                }
            }
        }
    }

    private func icon(for type: WorkoutSessionType) -> String {
        switch type {
        case .timer: return "timer"
        case .manual: return "plus.circle.fill"
        case .routine: return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Achievements

struct HomeAchievementsWidget: View {
    let unlocked: Int
    let total: Int
    let nextAchievement: AchievementDefinition?
    let onOpenSettings: () -> Void

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Achievements", subtitle: "\(unlocked) of \(total) unlocked", actionTitle: "View", action: onOpenSettings)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Color.appBackgroundFallback.opacity(0.4), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: total > 0 ? Double(unlocked) / Double(total) : 0)
                            .stroke(
                                LinearGradient(colors: [.appPrimary, .appAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                        Text("\(unlocked)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .frame(width: 64, height: 64)

                    if let nextAchievement {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Next up")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            HStack(spacing: 8) {
                                AppIconBadge(systemName: nextAchievement.systemImage, size: 32, tint: .appTextSecondary, background: Color.appBackgroundFallback.opacity(0.35))
                                Text(nextAchievement.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .lineLimit(2)
                            }
                        }
                    } else {
                        Text("All achievements unlocked. Great work!")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

// MARK: - Weekly insight

struct HomeInsightWidget: View {
    let insightText: String

    var body: some View {
        AppGlassCard {
            HStack(spacing: 14) {
                AppIconBadge(systemName: "sparkles", size: 44, tint: .appAccent, background: Color.appAccent.opacity(0.2))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Insight")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(insightText)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
