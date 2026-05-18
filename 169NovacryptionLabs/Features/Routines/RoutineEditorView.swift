import SwiftUI

struct RoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    @State var routine: ExerciseRoutine
    let isNew: Bool

    @State private var titleError: String?
    @State private var shakeTrigger = 0
    @State private var showSuccess = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: AppDesign.sectionSpacing) {
                        titleSection
                        tagsSection
                        exercisesSection
                    }
                    .padding(16)
                    .padding(.bottom, 24)
                }
                .appScreenStyle()
                .shake(trigger: shakeTrigger)
            }
            .navigationTitle(isNew ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundStyle(Color.appPrimary)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(editMode == .active ? "Done" : "Reorder") {
                        FeedbackManager.lightTap()
                        withAnimation { editMode = editMode == .active ? .inactive : .active }
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .overlay {
                SuccessCheckmarkOverlay(isVisible: $showSuccess)
            }
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
    }

    private var titleSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Routine Title")
                TextField("Routine Title", text: $routine.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(12)
                    .background(Color.appBackgroundFallback.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous))
                if let titleError {
                    Text(titleError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
    }

    private var tagsSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Tags", subtitle: "Tap to select categories")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(RoutineTag.allCases) { tag in
                        AppChip(
                            title: tag.rawValue,
                            isSelected: routine.tags.contains(tag.rawValue)
                        ) {
                            toggleTag(tag.rawValue)
                        }
                    }
                }
            }
        }
    }

    private var exercisesSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                AppSectionHeader(title: "Exercises", subtitle: "\(routine.exercises.count) items")

                if routine.exercises.isEmpty {
                    AppEmptyState(
                        icon: "plus.circle.fill",
                        title: "No Exercises",
                        message: "Add your first exercise to build this routine.",
                        buttonTitle: "Add Exercise",
                        action: addExercise
                    )
                } else {
                    ForEach(Array(routine.exercises.enumerated()), id: \.element.id) { index, _ in
                        exerciseEditorCard(
                            exercise: $routine.exercises[index],
                            index: index,
                            canReorder: editMode == .active
                        )
                    }
                }

                Button {
                    addExercise()
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.appPrimary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func exerciseEditorCard(exercise: Binding<ExerciseItem>, index: Int, canReorder: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Exercise name", text: exercise.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                if canReorder {
                    reorderControls(index: index)
                }
                Button {
                    FeedbackManager.lightTap()
                    routine.exercises.remove(at: index)
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .foregroundStyle(.red.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            TextField("Reps or duration", text: exercise.repsOrDuration)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
            AppStepperCell(
                title: "Rest",
                icon: "pause.fill",
                value: exercise.restSeconds,
                range: 0...300
            )
        }
        .padding(12)
        .appInsetPanel(cornerRadius: AppDesign.smallRadius)
    }

    private func reorderControls(index: Int) -> some View {
        HStack(spacing: 4) {
            Button {
                guard index > 0 else { return }
                FeedbackManager.lightTap()
                routine.exercises.swapAt(index, index - 1)
            } label: {
                Image(systemName: "chevron.up.circle.fill")
                    .foregroundStyle(Color.appPrimary)
            }
            .buttonStyle(.plain)
            .disabled(index == 0)
            Button {
                guard index < routine.exercises.count - 1 else { return }
                FeedbackManager.lightTap()
                routine.exercises.swapAt(index, index + 1)
            } label: {
                Image(systemName: "chevron.down.circle.fill")
                    .foregroundStyle(Color.appPrimary)
            }
            .buttonStyle(.plain)
            .disabled(index >= routine.exercises.count - 1)
        }
    }

    private func addExercise() {
        FeedbackManager.lightTap()
        routine.exercises.append(ExerciseItem())
    }

    private func toggleTag(_ tag: String) {
        if let index = routine.tags.firstIndex(of: tag) {
            routine.tags.remove(at: index)
        } else {
            routine.tags.append(tag)
        }
    }

    private func save() {
        let trimmed = routine.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            titleError = "Enter a routine title."
            shakeTrigger += 1
            FeedbackManager.warning()
            return
        }
        routine.title = trimmed
        routine.exercises = routine.exercises.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }

        if isNew {
            store.addRoutine(routine)
        } else {
            store.updateRoutine(routine)
        }

        FeedbackManager.mediumImpact()
        FeedbackManager.success()
        showSuccess = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSuccess = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}
