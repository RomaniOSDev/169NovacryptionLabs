import Combine
import Foundation
import SwiftUI

final class ProgressViewModel: ObservableObject {
    @Published var weekOffset: Int = 0
    @Published var showLogSheet = false
    @Published var logMinutes: Int = 30
    @Published var minutesError: String?
    @Published var shakeTrigger = 0
    @Published var showSuccess = false
    @Published var showNoteSheet = false
    @Published var workoutNote = ""

    func referenceDate() -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) ?? Date()
    }

    func weekTitle(store: AppDataStore) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let days = store.weekDays(reference: referenceDate())
        guard let first = days.first, let last = days.last else { return "This Week" }
        if weekOffset == 0 { return "This Week" }
        return "\(formatter.string(from: first)) – \(formatter.string(from: last))"
    }

    func weekdayInitial(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }

    func barData(store: AppDataStore) -> [(label: String, minutes: Int)] {
        store.weekDays(reference: referenceDate()).map { date in
            (weekdayInitial(date), store.minutesForDate(date))
        }
    }

    func hasWeekData(store: AppDataStore) -> Bool {
        barData(store: store).contains { $0.minutes > 0 }
    }

    func logWorkout(store: AppDataStore) {
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

    func saveLoggedWorkout(store: AppDataStore, skipNote: Bool = false) {
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
        FeedbackManager.logWorkout()
        FeedbackManager.success()
        showSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showSuccess = false
        }
    }
}
