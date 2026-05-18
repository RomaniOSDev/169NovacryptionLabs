import Combine
import Foundation

enum RoutinePlayerPhase {
    case idle, work, rest, finished
}

final class RoutinePlayerViewModel: ObservableObject {
    @Published var routine: ExerciseRoutine
    @Published var phase: RoutinePlayerPhase = .idle
    @Published var exerciseIndex = 0
    @Published var secondsRemaining = 0
    @Published var isRunning = false
    @Published var phaseDuration = 0
    @Published var showSuccessCheck = false

    private var store: AppDataStore?
    private var sessionStart: Date?
    private var phaseStartDate: Date?
    private var tickTimer: AnyCancellable?

    init(routine: ExerciseRoutine) {
        self.routine = routine
    }

    func bind(store: AppDataStore) {
        self.store = store
        syncRoutine(from: store)
    }

    func syncRoutine(from store: AppDataStore) {
        guard let latest = store.exerciseRoutines.first(where: { $0.id == routine.id }) else { return }
        routine = latest
        if exerciseIndex >= routine.exercises.count {
            exerciseIndex = max(routine.exercises.count - 1, 0)
        }
    }

    var hasExercises: Bool {
        !playableExercises.isEmpty
    }

    var playableExercises: [ExerciseItem] {
        routine.exercises.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var displayedExercise: ExerciseItem? {
        guard exerciseIndex >= 0, exerciseIndex < playableExercises.count else { return nil }
        return playableExercises[exerciseIndex]
    }

    var phaseLabel: String {
        switch phase {
        case .idle: return "Ready"
        case .work: return displayedExercise?.name ?? "Work"
        case .rest: return "Rest"
        case .finished: return "Complete"
        }
    }

    var progress: Double {
        guard phaseDuration > 0 else { return 0 }
        return min(max(1 - Double(secondsRemaining) / Double(phaseDuration), 0), 1)
    }

    func start() {
        guard hasExercises else { return }
        FeedbackManager.mediumImpact()
        exerciseIndex = 0
        sessionStart = Date()
        isRunning = true
        phase = .idle
        guard beginWorkPhase() else {
            isRunning = false
            phase = .idle
            return
        }
        startTicking()
    }

    func stop() {
        stopTicking()
        isRunning = false
        phase = .idle
        secondsRemaining = 0
        phaseDuration = 0
        phaseStartDate = nil
        exerciseIndex = 0
    }

    private func startTicking() {
        stopTicking()
        tickTimer = Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick(at: Date())
            }
    }

    private func stopTicking() {
        tickTimer?.cancel()
        tickTimer = nil
    }

    private func tick(at date: Date) {
        guard isRunning else { return }
        secondsRemaining = remainingSeconds(at: date)
        if secondsRemaining <= 0 {
            advancePhase()
        }
    }

    private func remainingSeconds(at date: Date) -> Int {
        guard let start = phaseStartDate, phaseDuration > 0 else { return secondsRemaining }
        let elapsed = Int(date.timeIntervalSince(start))
        return max(phaseDuration - elapsed, 0)
    }

    @discardableResult
    private func beginWorkPhase() -> Bool {
        guard let exercise = displayedExercise else { return false }
        phase = .work
        phaseDuration = max(exercise.workSecondsEstimate, 5)
        secondsRemaining = phaseDuration
        phaseStartDate = Date()
        return true
    }

    @discardableResult
    private func beginRestPhase() -> Bool {
        guard let exercise = displayedExercise else { return false }
        let rest = max(exercise.restSeconds, 0)
        guard rest > 0 else { return false }
        phase = .rest
        phaseDuration = rest
        secondsRemaining = rest
        phaseStartDate = Date()
        return true
    }

    private func advancePhase() {
        FeedbackManager.intervalEnd()
        switch phase {
        case .work:
            if beginRestPhase() {
                return
            }
            moveToNextExercise()
        case .rest:
            moveToNextExercise()
        case .idle:
            if isRunning {
                _ = beginWorkPhase()
            }
        case .finished:
            break
        }
    }

    private func moveToNextExercise() {
        if let exercise = displayedExercise, let store {
            if !store.completedExercises.contains(exercise.id) {
                store.completedExercises.insert(exercise.id)
            }
        }
        exerciseIndex += 1
        if exerciseIndex >= playableExercises.count {
            completeRoutine()
        } else if !beginWorkPhase() {
            completeRoutine()
        }
    }

    private func completeRoutine() {
        stopTicking()
        isRunning = false
        phase = .finished
        let minutes = max(Int(Date().timeIntervalSince(sessionStart ?? Date()) / 60), 1)
        store?.pendingWorkoutNote = PendingWorkoutNote(
            minutes: minutes,
            rounds: playableExercises.count,
            type: .routine,
            routineTitle: routine.title,
            templateName: nil
        )
        FeedbackManager.success()
        showSuccessCheck = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccessCheck = false
        }
    }

    func formattedTime(_ seconds: Int) -> String {
        String(format: "%02d:%02d", max(seconds, 0) / 60, max(seconds, 0) % 60)
    }
}
