import Foundation

enum InAppReminderService {
    static func shouldShowReminder(store: AppDataStore) -> Bool {
        guard store.reminderEnabled else { return false }
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = store.reminderHour
        components.minute = store.reminderMinute
        guard let reminderDate = calendar.date(from: components), now >= reminderDate else {
            return false
        }
        let todayKey = AppDataStore.dateKey(now)
        let trainedToday = store.sessionHistory.contains {
            AppDataStore.dateKey($0.date) == todayKey
        }
        return !trainedToday
    }

    static func weeklyReportText(store: AppDataStore) -> String {
        let sessions = store.sessionsThisWeek()
        let minutes = store.minutesThisWeek()
        let days = store.activeDaysThisWeek()
        return "You trained \(days) days, completed \(sessions) sessions, and worked out for \(minutes) minutes this week."
    }
}
