import SwiftUI

struct ActivityCalendarView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Activity Calendar", subtitle: "Last 6 weeks")

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(store.calendarDays(), id: \.self) { date in
                        dayCell(date)
                    }
                }
            }
        }
    }

    private func dayCell(_ date: Date) -> some View {
        let minutes = store.minutesForDate(date)
        let intensity = min(Double(minutes) / 60.0, 1.0)
        let day = Calendar.current.component(.day, from: date)
        let isToday = AppDataStore.dateKey(date) == AppDataStore.dateKey(Date())

        return VStack(spacing: 5) {
            Text("\(day)")
                .font(.system(size: 10, weight: isToday ? .heavy : .medium))
                .foregroundStyle(isToday ? Color.appPrimary : Color.appTextSecondary)
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    minutes > 0
                        ? Color.appAccent.opacity(0.25 + intensity * 0.75)
                        : Color.appBackgroundFallback.opacity(0.35)
                )
                .frame(height: 26)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(isToday ? Color.appPrimary : Color.clear, lineWidth: 1.5)
                )
        }
    }
}
