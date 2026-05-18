import Foundation
import Combine
import SwiftUI

enum TimerPhase: String {
    case idle, work, rest, finished
}

final class TimerViewModel: ObservableObject {
    @Published var workInput: Int = 30
    @Published var restInput: Int = 15
    @Published var roundsInput: Int = 5
    @Published var phase: TimerPhase = .idle
    @Published var currentRound = 1
    @Published var secondsRemaining = 0
    @Published var isRunning = false
    @Published var validationError: String?
    @Published var shakeTrigger = 0
    @Published var showSuccessCheck = false
    @Published var phaseStartDate: Date?
    @Published var phaseDuration: Int = 0

    private var store: AppDataStore?
    private var sessionStartDate: Date?

    func bind(store: AppDataStore) {
        self.store = store
        if store.timerConfigured {
            workInput = store.workSeconds
            restInput = store.restSeconds
            roundsInput = store.roundsCount
        }
    }

    var hasConfiguration: Bool {
        guard let store else { return false }
        return store.timerConfigured
    }

    var totalDurationText: String {
        let total = (workInput + restInput) * roundsInput - restInput
        guard total > 0 else { return "0 min" }
        let minutes = total / 60
        let seconds = total % 60
        if seconds == 0 { return "\(minutes) min total" }
        return "\(minutes) min \(seconds)s total"
    }

    var progress: Double {
        progress(at: Date())
    }

    func progress(at date: Date) -> Double {
        guard phaseDuration > 0 else { return 0 }
        let remaining = isRunning ? remainingSeconds(at: date) : secondsRemaining
        return 1 - Double(remaining) / Double(phaseDuration)
    }

    var phaseLabel: String {
        switch phase {
        case .idle: return "Ready"
        case .work: return "Work"
        case .rest: return "Rest"
        case .finished: return "Complete"
        }
    }

    @discardableResult
    func saveConfiguration() -> Bool {
        applyConfiguration(showFeedback: true)
    }

    @discardableResult
    private func applyConfiguration(showFeedback: Bool) -> Bool {
        guard workInput > 0, restInput >= 0, roundsInput > 0 else {
            validationError = "Enter valid interval values."
            shakeTrigger += 1
            FeedbackManager.warning()
            return false
        }
        validationError = nil
        store?.configureTimer(work: workInput, rest: restInput, rounds: roundsInput)
        if showFeedback {
            FeedbackManager.mediumImpact()
            FeedbackManager.success()
            triggerSuccessCheckmark()
        }
        return true
    }

    func start() {
        guard applyConfiguration(showFeedback: false) else { return }
        FeedbackManager.mediumImpact()
        currentRound = 1
        sessionStartDate = Date()
        beginWorkPhase()
        isRunning = true
    }

    func stop() {
        isRunning = false
        phase = .idle
        secondsRemaining = 0
        phaseStartDate = nil
        sessionStartDate = nil
    }

    func remainingSeconds(at date: Date) -> Int {
        guard isRunning, let start = phaseStartDate else { return secondsRemaining }
        let elapsed = Int(date.timeIntervalSince(start))
        return max(phaseDuration - elapsed, 0)
    }

    func tick(at date: Date) {
        guard isRunning else { return }
        let remaining = remainingSeconds(at: date)
        secondsRemaining = remaining
        if remaining <= 0 {
            advancePhase()
        }
    }

    private func beginWorkPhase() {
        phase = .work
        phaseDuration = workInput
        secondsRemaining = workInput
        phaseStartDate = Date()
    }

    private func beginRestPhase() {
        phase = .rest
        phaseDuration = restInput
        secondsRemaining = restInput
        phaseStartDate = Date()
    }

    private func advancePhase() {
        FeedbackManager.intervalEnd()

        switch phase {
        case .work:
            if currentRound >= roundsInput {
                completeSession()
            } else if restInput > 0 {
                beginRestPhase()
            } else {
                currentRound += 1
                beginWorkPhase()
            }
        case .rest:
            currentRound += 1
            if currentRound > roundsInput {
                completeSession()
            } else {
                beginWorkPhase()
            }
        default:
            break
        }
    }

    private func completeSession() {
        isRunning = false
        phase = .finished
        secondsRemaining = 0

        let totalSeconds = (workInput + restInput) * roundsInput - restInput
        let minutes = max(totalSeconds / 60, 1)
        let templateName = store?.allTemplates.first {
            $0.workSeconds == workInput && $0.restSeconds == restInput && $0.roundsCount == roundsInput
        }?.name ?? "Custom Interval"

        store?.pendingWorkoutNote = PendingWorkoutNote(
            minutes: minutes,
            rounds: roundsInput,
            type: .timer,
            routineTitle: nil,
            templateName: templateName
        )

        FeedbackManager.success()
        triggerSuccessCheckmark()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.phase = .idle
            self?.currentRound = 1
        }
    }

    func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func triggerSuccessCheckmark() {
        showSuccessCheck = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccessCheck = false
        }
    }
}
