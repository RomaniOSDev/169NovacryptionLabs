import Combine
import Foundation
import SwiftUI

final class RoutinesViewModel: ObservableObject {
    @Published var showEditor = false
    @Published var editingRoutine: ExerciseRoutine?
    @Published var pulseExerciseId: UUID?
    @Published var selectedTag: String?
    @Published var showArchived = false
    @Published var routineToPlay: ExerciseRoutine?

    func filteredRoutines(store: AppDataStore) -> [ExerciseRoutine] {
        let base = showArchived ? store.archivedRoutines : store.activeRoutines
        guard let selectedTag, !selectedTag.isEmpty else { return base }
        return base.filter { $0.tags.contains(selectedTag) }
    }

    func progress(for routine: ExerciseRoutine, store: AppDataStore) -> Double {
        guard !routine.exercises.isEmpty else { return 0 }
        let done = routine.exercises.filter { store.completedExercises.contains($0.id) }.count
        return Double(done) / Double(routine.exercises.count)
    }

    func overallProgress(store: AppDataStore) -> Double {
        let all = filteredRoutines(store: store).flatMap(\.exercises)
        guard !all.isEmpty else { return 0 }
        let done = all.filter { store.completedExercises.contains($0.id) }.count
        return Double(done) / Double(all.count)
    }

    func markComplete(exerciseId: UUID, store: AppDataStore) {
        let wasComplete = store.completedExercises.contains(exerciseId)
        store.toggleExerciseComplete(exerciseId)
        if !wasComplete {
            FeedbackManager.exerciseComplete()
            FeedbackManager.success()
            pulseExerciseId = exerciseId
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.pulseExerciseId = nil
            }
            AchievementManager.evaluate(store: store)
        }
    }
}
