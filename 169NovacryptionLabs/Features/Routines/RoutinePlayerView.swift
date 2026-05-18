import SwiftUI

struct RoutinePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel: RoutinePlayerViewModel
    @State private var workoutNote = ""
    @State private var showNoteSheet = false

    init(routine: ExerciseRoutine) {
        _viewModel = StateObject(wrappedValue: RoutinePlayerViewModel(routine: routine))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: AppDesign.sectionSpacing) {
                        exerciseCard
                        playerCard
                        controlsSection
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
                .appScreenStyle()
            }
            .navigationTitle(viewModel.routine.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
            }
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccessCheck)
            }
        }
        .onAppear {
            viewModel.bind(store: store)
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active, viewModel.isRunning { viewModel.stop() }
        }
        .onChange(of: store.pendingWorkoutNote?.minutes) { _ in
            if store.pendingWorkoutNote?.type == .routine {
                workoutNote = ""
                showNoteSheet = true
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            WorkoutNoteSheet(
                title: "Routine Complete",
                note: $workoutNote,
                onSave: { saveNote() },
                onSkip: { saveNote(skip: true) }
            )
        }
    }

    @ViewBuilder
    private var exerciseCard: some View {
        if let exercise = viewModel.displayedExercise {
            AppGlassCard {
                HStack(spacing: 14) {
                    AppIconBadge(systemName: "figure.strengthtraining.traditional", size: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.appTextPrimary)
                        if !exercise.repsOrDuration.isEmpty {
                            Text(exercise.repsOrDuration)
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Text("Rest \(exercise.restSeconds)s")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appBackgroundFallback)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.appPrimary)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
        } else {
            AppGlassCard {
                AppEmptyState(
                    icon: "exclamationmark.triangle.fill",
                    title: "No Exercises",
                    message: "Add at least one exercise with a name to run this routine."
                )
            }
        }
    }

    private var playerCard: some View {
        AppGlassCard(accentGlow: true) {
            VStack(spacing: 16) {
                playerCircle
                if viewModel.hasExercises {
                    Text("Exercise \(min(viewModel.exerciseIndex + 1, viewModel.playableExercises.count)) of \(viewModel.playableExercises.count)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var controlsSection: some View {
        Group {
            if viewModel.hasExercises {
                if viewModel.isRunning {
                    PrimaryButton(title: "Stop Routine") {
                        viewModel.stop()
                    }
                } else {
                    PrimaryButton(title: "Start Routine") {
                        viewModel.start()
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private var playerCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.appBackgroundFallback.opacity(0.5), lineWidth: 14)
                .frame(width: 200, height: 200)
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    AppGradients.progress,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.2), value: viewModel.progress)
            VStack(spacing: 6) {
                Text(viewModel.phaseLabel)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                Text(viewModel.formattedTime(viewModel.secondsRemaining))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appTextPrimary)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 8)
    }

    private func saveNote(skip: Bool = false) {
        guard let pending = store.pendingWorkoutNote else {
            showNoteSheet = false
            dismiss()
            return
        }
        store.recordWorkoutCompleted(
            minutes: pending.minutes,
            rounds: pending.rounds,
            type: .routine,
            routineTitle: pending.routineTitle,
            note: skip ? "" : workoutNote
        )
        store.pendingWorkoutNote = nil
        showNoteSheet = false
        dismiss()
    }
}
