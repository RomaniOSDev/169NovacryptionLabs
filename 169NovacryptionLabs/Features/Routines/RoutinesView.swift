import SwiftUI

struct RoutinesView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = RoutinesViewModel()

    private var filteredRoutines: [ExerciseRoutine] {
        viewModel.filteredRoutines(store: store)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: AppDesign.sectionSpacing) {
                    filtersSection

                    if filteredRoutines.isEmpty {
                        AppEmptyState(
                            icon: "dumbbell.fill",
                            title: viewModel.showArchived ? "No Archived Routines" : "Add Your First Routine",
                            message: viewModel.showArchived
                                ? "Archived routines will appear here."
                                : "Build a custom plan with exercises, rest times, and tags.",
                            buttonTitle: viewModel.showArchived ? nil : "Create Routine",
                            action: viewModel.showArchived ? nil : {
                                viewModel.editingRoutine = nil
                                viewModel.showEditor = true
                            }
                        )
                    } else {
                        overallProgressCard

                        ForEach(filteredRoutines) { routine in
                            AppRoutineCard(
                                routine: routine,
                                progress: viewModel.progress(for: routine, store: store),
                                onStart: { viewModel.routineToPlay = routine },
                                onEdit: {
                                    viewModel.editingRoutine = routine
                                    viewModel.showEditor = true
                                }
                            ) {
                                VStack(spacing: 8) {
                                    ForEach(routine.exercises) { exercise in
                                        AppExerciseCell(
                                            name: exercise.name,
                                            detail: exercise.repsOrDuration,
                                            restText: "\(exercise.restSeconds)s rest",
                                            isDone: store.completedExercises.contains(exercise.id),
                                            isPulsing: viewModel.pulseExerciseId == exercise.id,
                                            onToggle: {
                                                viewModel.markComplete(exerciseId: exercise.id, store: store)
                                            }
                                        )
                                    }
                                }
                            }
                            .contextMenu { routineMenu(routine) }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 88)
            }
            .appScreenStyle()

            AppFloatingButton(icon: "plus") {
                viewModel.editingRoutine = nil
                viewModel.showEditor = true
            }
            .padding(20)
        }
        .sheet(isPresented: $viewModel.showEditor) {
            RoutineEditorView(
                routine: viewModel.editingRoutine ?? ExerciseRoutine(title: "", exercises: [ExerciseItem()]),
                isNew: viewModel.editingRoutine == nil
            )
        }
        .fullScreenCover(item: $viewModel.routineToPlay) { routine in
            RoutinePlayerView(routine: routine)
        }
    }

    private var filtersSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $viewModel.showArchived) {
                    Label("Show Archived", systemImage: "archivebox.fill")
                        .foregroundStyle(Color.appTextPrimary)
                }
                .tint(Color.appPrimary)

                if !store.allRoutineTags().isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            AppChip(title: "All", isSelected: viewModel.selectedTag == nil) {
                                viewModel.selectedTag = nil
                            }
                            ForEach(store.allRoutineTags(), id: \.self) { tag in
                                AppChip(title: tag, isSelected: viewModel.selectedTag == tag) {
                                    viewModel.selectedTag = tag
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var overallProgressCard: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Overall Progress", subtitle: "Across visible routines")
                AppProgressRow(
                    title: "Exercises completed",
                    valueText: "\(Int(viewModel.overallProgress(store: store) * 100))%",
                    progress: viewModel.overallProgress(store: store)
                )
            }
        }
    }

    @ViewBuilder
    private func routineMenu(_ routine: ExerciseRoutine) -> some View {
        Button("Start Routine") { viewModel.routineToPlay = routine }
        Button("Edit") {
            viewModel.editingRoutine = routine
            viewModel.showEditor = true
        }
        Button("Duplicate") { store.duplicateRoutine(routine) }
        Button(routine.isArchived ? "Unarchive" : "Archive") {
            store.setRoutineArchived(routine.id, archived: !routine.isArchived)
        }
        Button("Delete", role: .destructive) {
            if let index = store.exerciseRoutines.firstIndex(where: { $0.id == routine.id }) {
                store.exerciseRoutines.remove(at: index)
            }
        }
    }
}
