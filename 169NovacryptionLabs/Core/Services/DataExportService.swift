import Foundation

enum DataExportService {
    static func csv(from store: AppDataStore) -> String {
        var lines = ["Date,Type,Minutes,Rounds,Title,Note"]
        let formatter = ISO8601DateFormatter()
        for session in store.sessionHistory.sorted(by: { $0.date > $1.date }) {
            let date = formatter.string(from: session.date)
            let title = session.routineTitle ?? session.templateName ?? session.typeLabel
            let escapedNote = session.note.replacingOccurrences(of: "\"", with: "\"\"")
            lines.append("\(date),\(session.sessionType.rawValue),\(session.minutes),\(session.rounds),\"\(title)\",\"\(escapedNote)\"")
        }
        return lines.joined(separator: "\n")
    }

    static func backupJSON(from store: AppDataStore) -> Data? {
        let snapshot = AppBackupSnapshot(store: store)
        return try? JSONEncoder().encode(snapshot)
    }

    static func restoreJSON(_ data: Data, into store: AppDataStore) -> Bool {
        guard let snapshot = try? JSONDecoder().decode(AppBackupSnapshot.self, from: data) else {
            return false
        }
        snapshot.apply(to: store)
        AchievementManager.evaluate(store: store)
        return true
    }
}

struct AppBackupSnapshot: Codable {
    var sessionHistory: [WorkoutSessionRecord]
    var customTemplates: [IntervalTemplate]
    var exerciseRoutines: [ExerciseRoutine]
    var weeklyGoalSessions: Int
    var weeklyGoalMinutes: Int
    var weeklyWorkoutData: [String: Int]
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var workSeconds: Int
    var restSeconds: Int
    var roundsCount: Int

    init(store: AppDataStore) {
        sessionHistory = store.sessionHistory
        customTemplates = store.customTemplates
        exerciseRoutines = store.exerciseRoutines
        weeklyGoalSessions = store.weeklyGoalSessions
        weeklyGoalMinutes = store.weeklyGoalMinutes
        weeklyWorkoutData = store.weeklyWorkoutData
        reminderEnabled = store.reminderEnabled
        reminderHour = store.reminderHour
        reminderMinute = store.reminderMinute
        workSeconds = store.workSeconds
        restSeconds = store.restSeconds
        roundsCount = store.roundsCount
    }

    func apply(to store: AppDataStore) {
        store.sessionHistory = sessionHistory
        store.customTemplates = customTemplates
        store.exerciseRoutines = exerciseRoutines
        store.weeklyGoalSessions = weeklyGoalSessions
        store.weeklyGoalMinutes = weeklyGoalMinutes
        store.weeklyWorkoutData = weeklyWorkoutData
        store.reminderEnabled = reminderEnabled
        store.reminderHour = reminderHour
        store.reminderMinute = reminderMinute
        store.configureTimer(work: workSeconds, rest: restSeconds, rounds: roundsCount)
    }
}
