import SwiftUI

struct SessionHistoryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedSession: WorkoutSessionRecord?

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        Group {
            if store.sessionHistory.isEmpty {
                AppEmptyState(
                    icon: "clock.arrow.circlepath",
                    title: "No Sessions Yet",
                    message: "Complete a timer, routine, or log a workout to build your history."
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: AppDesign.itemSpacing) {
                        AppSectionHeader(
                            title: "Recent Sessions",
                            subtitle: "\(store.sessionHistory.count) total"
                        )
                        .padding(.horizontal, 16)

                        ForEach(store.sessionHistory) { session in
                            AppSessionCell(
                                session: session,
                                dateText: dateFormatter.string(from: session.date)
                            ) {
                                selectedSession = session
                            }
                            .padding(.horizontal, 16)
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    store.deleteSession(session.id)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
                .appScreenStyle()
            }
        }
        .sheet(item: $selectedSession) { session in
            SessionDetailSheet(session: session)
        }
    }
}

private struct SessionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore
    let session: WorkoutSessionRecord
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: AppDesign.itemSpacing) {
                        AppGlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                AppSectionHeader(title: "Session Details")
                                detailRow("Type", session.typeLabel)
                                detailRow("Minutes", "\(session.minutes)")
                                if session.rounds > 0 {
                                    detailRow("Rounds", "\(session.rounds)")
                                }
                            }
                        }
                        AppGlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                AppSectionHeader(title: "Note")
                                TextField("How did it feel?", text: $note, axis: .vertical)
                                    .lineLimit(3...8)
                                    .padding(12)
                                    .background(Color.appBackgroundFallback.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous))
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                        }
                        PrimaryButton(title: "Save Note") {
                            store.updateSessionNote(session.id, note: note)
                            FeedbackManager.mediumImpact()
                            dismiss()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
        .onAppear { note = session.note }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
    }
}
