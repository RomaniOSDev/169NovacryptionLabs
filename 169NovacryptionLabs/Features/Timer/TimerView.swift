import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = TimerViewModel()
    @State private var workoutNote = ""
    @State private var showNoteSheet = false

    var body: some View {
        AppNavigationShell(title: "Interval Timer") {
            ScrollView {
                VStack(spacing: AppDesign.sectionSpacing) {
                    if !viewModel.hasConfiguration && !store.timerConfigured {
                        AppEmptyState(
                            icon: "stopwatch",
                            title: "No Intervals Set Yet",
                            message: "Choose a template below or configure work, rest, and rounds."
                        )
                    }

                    IntervalTemplatesView(
                        workInput: $viewModel.workInput,
                        restInput: $viewModel.restInput,
                        roundsInput: $viewModel.roundsInput
                    )

                    AppGlassCard {
                        VStack(spacing: 12) {
                            AppSectionHeader(title: "Configuration", subtitle: "Customize your session")
                            AppStepperCell(title: "Work Seconds", icon: "flame.fill", value: $viewModel.workInput, range: 1...600, errorText: viewModel.validationError, shakeTrigger: viewModel.shakeTrigger)
                            AppStepperCell(title: "Rest Seconds", icon: "pause.fill", value: $viewModel.restInput, range: 0...300)
                            AppStepperCell(title: "Rounds Count", icon: "repeat", value: $viewModel.roundsInput, range: 1...50)
                        }
                    }

                    timerDialCard

                    if store.timerConfigured || viewModel.workInput > 0 {
                        AppGlassCard(padding: 12) {
                            HStack {
                                AppIconBadge(systemName: "clock.fill", size: 36, tint: .appAccent)
                                Text(viewModel.totalDurationText)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                            }
                        }
                    }

                    VStack(spacing: 12) {
                        if viewModel.isRunning {
                            PrimaryButton(title: "Stop Timer") { viewModel.stop() }
                        } else {
                            PrimaryButton(title: "Start Timer") { viewModel.start() }
                            if !store.timerConfigured {
                                Button("Save Configuration") {
                                    _ = viewModel.saveConfiguration()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                                .frame(minHeight: 44)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .appScreenStyle()
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheck)
            }
        }
        .onAppear { viewModel.bind(store: store) }
        .onChange(of: scenePhase) { phase in
            if phase != .active, viewModel.isRunning { viewModel.stop() }
        }
        .onChange(of: store.pendingWorkoutNote?.minutes) { _ in
            if store.pendingWorkoutNote != nil {
                workoutNote = ""
                showNoteSheet = true
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            WorkoutNoteSheet(
                title: "Session Note",
                note: $workoutNote,
                onSave: { saveWorkoutNote() },
                onSkip: { saveWorkoutNote(skipNote: true) }
            )
        }
    }

    private func saveWorkoutNote(skipNote: Bool = false) {
        guard let pending = store.pendingWorkoutNote else {
            showNoteSheet = false
            return
        }
        store.recordWorkoutCompleted(
            minutes: pending.minutes,
            rounds: pending.rounds,
            type: pending.type,
            routineTitle: pending.routineTitle,
            templateName: pending.templateName,
            note: skipNote ? "" : workoutNote
        )
        store.pendingWorkoutNote = nil
        showNoteSheet = false
        FeedbackManager.success()
    }

    private var timerDialCard: some View {
        AppGlassCard(accentGlow: true) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.appBackgroundFallback.opacity(0.45), lineWidth: 14)
                        .frame(width: 220, height: 220)
                    if viewModel.isRunning {
                        TimelineView(.periodic(from: .now, by: 0.2)) { context in
                            Circle()
                                .trim(from: 0, to: viewModel.progress(at: context.date))
                                .stroke(
                                    AppGradients.progress,
                                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                )
                                .frame(width: 220, height: 220)
                                .rotationEffect(.degrees(-90))
                        }
                    } else {
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                AppGradients.progress,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                    }
                    VStack(spacing: 8) {
                        Text(viewModel.phaseLabel.uppercased())
                            .font(.caption.weight(.heavy))
                            .foregroundStyle(Color.appAccent)
                            .tracking(1.2)
                        if viewModel.isRunning {
                            TimelineView(.periodic(from: .now, by: 0.2)) { context in
                                TimerTickView(viewModel: viewModel, date: context.date)
                            }
                        } else {
                            Text(viewModel.formattedTime(store.workSeconds > 0 ? store.workSeconds : viewModel.workInput))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        if viewModel.isRunning {
                            Text("Round \(viewModel.currentRound) / \(viewModel.roundsInput)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct TimerTickView: View {
    @ObservedObject var viewModel: TimerViewModel
    let date: Date

    var body: some View {
        let remaining = viewModel.remainingSeconds(at: date)
        Text(viewModel.formattedTime(remaining))
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundStyle(Color.appTextPrimary)
            .onChange(of: date) { newDate in
                let value = viewModel.remainingSeconds(at: newDate)
                viewModel.secondsRemaining = value
                if value <= 0 { viewModel.tick(at: newDate) }
            }
    }
}
