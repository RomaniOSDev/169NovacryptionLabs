import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab
    @Binding var trainSegment: Int

    @State private var showLogSheet = false
    @State private var showNoteSheet = false
    @State private var logMinutes = 30
    @State private var workoutNote = ""
    @State private var minutesError: String?
    @State private var shakeTrigger = 0
    @State private var routineToPlay: ExerciseRoutine?
    @State private var selectedSession: WorkoutSessionRecord?

    var body: some View {
        AppNavigationShell(title: "Home") {
            ScrollView {
                VStack(spacing: AppDesign.sectionSpacing) {
                    HomeHeroWidget(
                        greeting: greeting,
                        dateText: dateText,
                        streak: store.streakDays,
                        minutesToday: store.minutesToday(),
                        trainedToday: store.trainedToday()
                    )

                    HomeQuickActionWidget(
                        onTimer: { selectedTab = .timer },
                        onLog: { showLogSheet = true },
                        onRoutines: { openTrain(segment: 0) },
                        onProgress: { openTrain(segment: 1) }
                    )

                    HomeGoalsWidget(
                        sessionsProgress: store.weeklySessionProgress,
                        minutesProgress: store.weeklyMinutesProgress,
                        sessionsText: "\(store.sessionsThisWeek()) / \(store.weeklyGoalSessions)",
                        minutesText: "\(store.minutesThisWeek()) / \(store.weeklyGoalMinutes)"
                    )

                    HomeWeekActivityWidget(days: weekActivityDays)

                    HomeTimerSnapshotWidget(
                        workSeconds: store.workSeconds,
                        restSeconds: store.restSeconds,
                        rounds: store.roundsCount,
                        isConfigured: store.timerConfigured,
                        onOpen: { selectedTab = .timer }
                    )

                    HomeRoutineQuickStartWidget(
                        routines: store.activeRoutines,
                        onStart: { routineToPlay = $0 },
                        onSeeAll: { openTrain(segment: 0) }
                    )

                    HomeInsightWidget(insightText: InAppReminderService.weeklyReportText(store: store))

                    HomeRecentSessionsWidget(
                        sessions: Array(store.sessionHistory.prefix(3)),
                        onSeeAll: { openTrain(segment: 2) },
                        onSelect: { selectedSession = $0 }
                    )

                    HomeAchievementsWidget(
                        unlocked: unlockedAchievementsCount,
                        total: AchievementDefinition.all.count,
                        nextAchievement: nextLockedAchievement,
                        onOpenSettings: { selectedTab = .settings }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .appScreenStyle()
        }
        .sheet(isPresented: $showLogSheet) { logWorkoutSheet }
        .sheet(isPresented: $showNoteSheet) {
            WorkoutNoteSheet(
                title: "Log Workout",
                note: $workoutNote,
                onSave: { saveLoggedWorkout() },
                onSkip: { saveLoggedWorkout(skipNote: true) }
            )
        }
        .fullScreenCover(item: $routineToPlay) { routine in
            RoutinePlayerView(routine: routine)
        }
        .sheet(item: $selectedSession) { session in
            HomeSessionDetailSheet(session: session) { note in
                store.updateSessionNote(session.id, note: note)
                selectedSession = nil
            }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    private var weekActivityDays: [(label: String, minutes: Int, isToday: Bool)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        let todayKey = AppDataStore.dateKey(Date())
        return store.weekDays().map { date in
            (
                formatter.string(from: date),
                store.minutesForDate(date),
                AppDataStore.dateKey(date) == todayKey
            )
        }
    }

    private var unlockedAchievementsCount: Int {
        AchievementDefinition.all.filter { AchievementManager.isUnlocked($0, store: store) }.count
    }

    private var nextLockedAchievement: AchievementDefinition? {
        AchievementDefinition.all.first { !AchievementManager.isUnlocked($0, store: store) }
    }

    private func openTrain(segment: Int) {
        trainSegment = segment
        selectedTab = .train
    }

    private var logWorkoutSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 16) {
                    AppStepperCell(
                        title: "Minutes",
                        icon: "plus.circle.fill",
                        value: $logMinutes,
                        range: 1...600,
                        errorText: minutesError,
                        shakeTrigger: shakeTrigger
                    )
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        showLogSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        continueLog()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func continueLog() {
        guard logMinutes > 0, logMinutes <= 600 else {
            minutesError = "Enter minutes between 1 and 600."
            shakeTrigger += 1
            FeedbackManager.warning()
            return
        }
        minutesError = nil
        store.pendingWorkoutNote = PendingWorkoutNote(
            minutes: logMinutes,
            rounds: 0,
            type: .manual,
            routineTitle: nil,
            templateName: nil
        )
        workoutNote = ""
        showLogSheet = false
        showNoteSheet = true
    }

    private func saveLoggedWorkout(skipNote: Bool = false) {
        guard let pending = store.pendingWorkoutNote else {
            showNoteSheet = false
            return
        }
        store.recordWorkoutCompleted(
            minutes: pending.minutes,
            type: .manual,
            note: skipNote ? "" : workoutNote
        )
        store.pendingWorkoutNote = nil
        showNoteSheet = false
        FeedbackManager.success()
    }
}

// MARK: - Session detail

private struct HomeSessionDetailSheet: View {
    let session: WorkoutSessionRecord
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note: String

    init(session: WorkoutSessionRecord, onSave: @escaping (String) -> Void) {
        self.session = session
        self.onSave = onSave
        _note = State(initialValue: session.note)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 16) {
                    AppGlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            AppSectionHeader(title: session.typeLabel, subtitle: formattedDate)
                            HStack(spacing: 12) {
                                AppStatTile(icon: "clock.fill", title: "Duration", value: "\(session.minutes) min")
                                if session.rounds > 0 {
                                    AppStatTile(icon: "repeat", title: "Rounds", value: "\(session.rounds)")
                                }
                            }
                            TextField("Session note", text: $note, axis: .vertical)
                                .lineLimit(2...5)
                                .padding(12)
                                .background(Color.appBackgroundFallback.opacity(0.35))
                                .clipShape(RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        FeedbackManager.mediumImpact()
                        onSave(note)
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.date)
    }
}
