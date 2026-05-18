import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showShareCSV = false
    @State private var showShareBackup = false
    @State private var showImporter = false
    @State private var importError = false
    @State private var csvURL: URL?
    @State private var backupURL: URL?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        AppNavigationShell(title: "Settings") {
            ScrollView {
                VStack(spacing: AppDesign.sectionSpacing) {
                    statsCard
                    weeklyReportCard
                    reminderCard
                    achievementsSection
                    legalSection
                    dataSection
                    versionFooter
                }
                .padding(16)
                .padding(.bottom, 8)
            }
            .appScreenStyle()
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {
                    FeedbackManager.lightTap()
                }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackManager.warning()
                }
            } message: {
                Text("This will permanently delete all workouts, routines, and progress.")
            }
            .alert("Import Failed", isPresented: $importError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Could not restore backup file.")
            }
            .sheet(isPresented: $showShareCSV) {
                if let csvURL {
                    ShareSheet(items: [csvURL])
                }
            }
            .sheet(isPresented: $showShareBackup) {
                if let backupURL {
                    ShareSheet(items: [backupURL])
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                importBackup(result)
            }
        }
    }

    private var statsCard: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Your Stats", subtitle: "Lifetime activity")
                HStack(spacing: 12) {
                    AppStatTile(icon: "square.and.pencil", title: "Entries", value: "\(store.entriesCreated)")
                    AppStatTile(icon: "clock.fill", title: "Minutes", value: "\(store.totalMinutesUsed)")
                }
                HStack(spacing: 12) {
                    AppStatTile(icon: "flame.fill", title: "Streak", value: "\(store.streakDays)d", accent: .appPrimary)
                    AppStatTile(icon: "checkmark.circle.fill", title: "Sessions", value: "\(store.totalSessionsCompleted)")
                }
            }
        }
    }

    private var weeklyReportCard: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(title: "Weekly Report", subtitle: "Snapshot of this week")
                Text(InAppReminderService.weeklyReportText(store: store))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var reminderCard: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Reminders", subtitle: "In-app only, no push notifications")
                Toggle("Daily Workout Reminder", isOn: $store.reminderEnabled)
                    .tint(Color.appPrimary)
                    .foregroundStyle(Color.appTextPrimary)
                    .onChange(of: store.reminderEnabled) { enabled in
                        FeedbackManager.lightTap()
                        if enabled { store.dismissedReminderDate = nil }
                    }

                if store.reminderEnabled {
                    HStack {
                        Picker("Hour", selection: $store.reminderHour) {
                            ForEach(6..<23, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        Picker("Minute", selection: $store.reminderMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                    Text("Shows an in-app reminder when you open the app after your chosen time.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }

    private var achievementsSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    title: "Achievements",
                    subtitle: "\(unlockedCount) of \(AchievementDefinition.all.count) unlocked"
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AchievementDefinition.all) { achievement in
                        AchievementBadgeView(
                            achievement: achievement,
                            isUnlocked: AchievementManager.isUnlocked(achievement, store: store)
                        )
                    }
                }

                Divider().overlay(Color.white.opacity(0.12))

                HStack(spacing: 12) {
                    AppStatTile(icon: "figure.run", title: "Workouts", value: "\(store.workoutsCompleted)")
                    AppStatTile(icon: "repeat", title: "Rounds", value: "\(store.roundsCompleted)")
                    AppStatTile(icon: "trophy.fill", title: "Best", value: "\(store.longestSessionMinutes)m", accent: .appPrimary)
                }
            }
        }
    }

    private var unlockedCount: Int {
        AchievementDefinition.all.filter { AchievementManager.isUnlocked($0, store: store) }.count
    }

    private var legalSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 4) {
                AppSectionHeader(title: "Feedback & Legal")
                AppActionRow(icon: "star.fill", title: "Rate Us", subtitle: "Enjoying the app?") {
                    FeedbackManager.lightTap()
                    SettingsActions.rateApp()
                }
                Divider().overlay(Color.white.opacity(0.08))
                AppActionRow(icon: AppExternalLink.privacyPolicy.systemImage, title: AppExternalLink.privacyPolicy.title) {
                    FeedbackManager.lightTap()
                    SettingsActions.open(.privacyPolicy)
                }
                Divider().overlay(Color.white.opacity(0.08))
                AppActionRow(icon: AppExternalLink.termsOfUse.systemImage, title: AppExternalLink.termsOfUse.title) {
                    FeedbackManager.lightTap()
                    SettingsActions.open(.termsOfUse)
                }
            }
        }
    }

    private var dataSection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 4) {
                AppSectionHeader(title: "Data & Support")
                AppActionRow(icon: "square.and.arrow.up", title: "Export CSV", subtitle: "Spreadsheet format") {
                    exportCSV()
                }
                Divider().overlay(Color.white.opacity(0.08))
                AppActionRow(icon: "externaldrive", title: "Export Backup", subtitle: "Full JSON backup") {
                    exportBackup()
                }
                Divider().overlay(Color.white.opacity(0.08))
                AppActionRow(icon: "square.and.arrow.down", title: "Import Backup", subtitle: "Restore from JSON") {
                    showImporter = true
                }
                Divider().overlay(Color.white.opacity(0.08))
                AppActionRow(icon: "trash.fill", title: "Reset All Data", showsChevron: false, isDestructive: true) {
                    showResetAlert = true
                }
            }
        }
    }

    private func exportCSV() {
        let csv = DataExportService.csv(from: store)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("workouts_export.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            csvURL = url
            showShareCSV = true
            FeedbackManager.mediumImpact()
        } catch {
            FeedbackManager.warning()
        }
    }

    private func exportBackup() {
        guard let data = DataExportService.backupJSON(from: store) else {
            FeedbackManager.warning()
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("activeaid_backup.json")
        do {
            try data.write(to: url)
            backupURL = url
            showShareBackup = true
            FeedbackManager.mediumImpact()
        } catch {
            FeedbackManager.warning()
        }
    }

    private func importBackup(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url),
              DataExportService.restoreJSON(data, into: store) else {
            importError = true
            FeedbackManager.warning()
            return
        }
        FeedbackManager.success()
    }

    private var versionFooter: some View {
        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
            .font(.caption)
            .foregroundStyle(Color.appTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }
}

private struct AchievementBadgeView: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            AppIconBadge(
                systemName: achievement.systemImage,
                size: 44,
                tint: isUnlocked ? .appPrimary : .appTextSecondary,
                background: isUnlocked ? Color.appPrimary.opacity(0.22) : Color.appBackgroundFallback.opacity(0.35)
            )
            Text(achievement.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isUnlocked ? Color.appTextPrimary : Color.appTextPrimary.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 108)
        .background {
            let shape = RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
            if isUnlocked {
                shape
                    .fill(Color.appPrimary.opacity(0.15))
                    .overlay(shape.fill(AppGradients.primary).opacity(0.65))
                    .overlay(shape.stroke(Color.appPrimary.opacity(0.45), lineWidth: 1))
                    .compositingGroup()
                    .shadow(color: Color.appPrimary.opacity(0.2), radius: 6, y: 3)
            } else {
                shape.fill(AppGradients.surfaceInset)
            }
        }
        .opacity(isUnlocked ? 1 : 0.65)
    }
}
