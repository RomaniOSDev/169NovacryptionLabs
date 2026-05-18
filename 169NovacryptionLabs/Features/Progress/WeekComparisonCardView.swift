import SwiftUI

struct WeekComparisonCardView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Week Comparison", subtitle: "This week vs last week")

                HStack(spacing: 12) {
                    comparisonTile(
                        title: "This Week",
                        sessions: store.sessionsThisWeek(),
                        minutes: store.minutesThisWeek(),
                        highlighted: true
                    )
                    comparisonTile(
                        title: "Last Week",
                        sessions: store.sessionsLastWeek(),
                        minutes: store.minutesLastWeek(),
                        highlighted: false
                    )
                }

                let delta = store.minutesThisWeek() - store.minutesLastWeek()
                HStack(spacing: 8) {
                    Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(delta >= 0 ? "+\(delta) min vs last week" : "\(delta) min vs last week")
                        .font(.caption.weight(.bold))
                }
                .foregroundStyle(delta >= 0 ? Color.appAccent : Color.appTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.appBackgroundFallback.opacity(0.28))
                .clipShape(Capsule())
            }
        }
    }

    private func comparisonTile(title: String, sessions: Int, minutes: Int, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text("\(sessions)")
                .font(.title2.weight(.bold))
                .foregroundStyle(highlighted ? Color.appAccent : Color.appTextPrimary)
            Text("sessions")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
            Text("\(minutes) min")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            let shape = RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
            if highlighted {
                shape
                    .fill(Color.appPrimary.opacity(0.18))
                    .overlay(shape.fill(AppGradients.primary).opacity(0.7))
                    .overlay(shape.stroke(Color.appPrimary.opacity(0.45), lineWidth: 1))
            } else {
                shape.fill(AppGradients.surfaceInset)
            }
        }
    }
}
