import SwiftUI

struct WorkoutNoteSheet: View {
    let title: String
    @Binding var note: String
    let onSave: () -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(alignment: .leading, spacing: 16) {
                    AppGlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            AppSectionHeader(title: "Session Note", subtitle: "Optional reflection")
                            Text("Add an optional note about how this session felt.")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            TextField("How did it feel?", text: $note, axis: .vertical)
                                .lineLimit(3...6)
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        FeedbackManager.lightTap()
                        onSkip()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        FeedbackManager.mediumImpact()
                        onSave()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
    }
}
