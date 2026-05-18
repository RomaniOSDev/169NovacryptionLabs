import SwiftUI

struct WeeklyGoalsCardView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 16) {
                AppSectionHeader(title: "Weekly Goals", subtitle: "Track sessions and minutes")

                AppProgressRow(
                    title: "Sessions",
                    valueText: "\(store.sessionsThisWeek()) / \(store.weeklyGoalSessions)",
                    progress: store.weeklySessionProgress
                )
                AppProgressRow(
                    title: "Minutes",
                    valueText: "\(store.minutesThisWeek()) / \(store.weeklyGoalMinutes)",
                    progress: store.weeklyMinutesProgress
                )

                Divider().overlay(Color.white.opacity(0.12))

                AppStepperCell(title: "Session Goal", icon: "flag.fill", value: $store.weeklyGoalSessions, range: 1...14)
                AppStepperCell(title: "Minute Goal", icon: "clock.fill", value: $store.weeklyGoalMinutes, range: 30...600)
            }
        }
    }
}
