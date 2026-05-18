import Foundation
import Combine

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let workoutsCompleted = "workoutsCompleted"
        static let roundsCompleted = "roundsCompleted"
        static let longestSessionMinutes = "longestSessionMinutes"
        static let workSeconds = "workSeconds"
        static let restSeconds = "restSeconds"
        static let roundsCount = "roundsCount"
        static let timerConfigured = "timerConfigured"
        static let exerciseRoutines = "exerciseRoutines"
        static let completedExercises = "completedExercises"
        static let completedSessionsCount = "completedSessionsCount"
        static let totalMinutesWorkedOut = "totalMinutesWorkedOut"
        static let weeklyWorkoutData = "weeklyWorkoutData"
        static let entriesCreated = "entriesCreated"
        static let sessionHistory = "sessionHistory"
        static let customTemplates = "customTemplates"
        static let weeklyGoalSessions = "weeklyGoalSessions"
        static let weeklyGoalMinutes = "weeklyGoalMinutes"
        static let reminderEnabled = "reminderEnabled"
        static let reminderHour = "reminderHour"
        static let reminderMinute = "reminderMinute"
        static let dismissedReminderDate = "dismissedReminderDate"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var workoutsCompleted: Int {
        didSet { defaults.set(workoutsCompleted, forKey: Keys.workoutsCompleted) }
    }

    @Published var roundsCompleted: Int {
        didSet { defaults.set(roundsCompleted, forKey: Keys.roundsCompleted) }
    }

    @Published var longestSessionMinutes: Int {
        didSet { defaults.set(longestSessionMinutes, forKey: Keys.longestSessionMinutes) }
    }

    @Published var workSeconds: Int {
        didSet { defaults.set(workSeconds, forKey: Keys.workSeconds) }
    }

    @Published var restSeconds: Int {
        didSet { defaults.set(restSeconds, forKey: Keys.restSeconds) }
    }

    @Published var roundsCount: Int {
        didSet { defaults.set(roundsCount, forKey: Keys.roundsCount) }
    }

    @Published var timerConfigured: Bool {
        didSet { defaults.set(timerConfigured, forKey: Keys.timerConfigured) }
    }

    @Published var exerciseRoutines: [ExerciseRoutine] {
        didSet { saveRoutines() }
    }

    @Published var completedExercises: Set<UUID> {
        didSet { saveCompletedExercises() }
    }

    @Published var completedSessionsCount: Int {
        didSet { defaults.set(completedSessionsCount, forKey: Keys.completedSessionsCount) }
    }

    @Published var totalMinutesWorkedOut: Int {
        didSet { defaults.set(totalMinutesWorkedOut, forKey: Keys.totalMinutesWorkedOut) }
    }

    @Published var weeklyWorkoutData: [String: Int] {
        didSet { saveWeeklyData() }
    }

    @Published var entriesCreated: Int {
        didSet { defaults.set(entriesCreated, forKey: Keys.entriesCreated) }
    }

    @Published var sessionHistory: [WorkoutSessionRecord] {
        didSet { saveSessionHistory() }
    }

    @Published var customTemplates: [IntervalTemplate] {
        didSet { saveCustomTemplates() }
    }

    @Published var weeklyGoalSessions: Int {
        didSet { defaults.set(weeklyGoalSessions, forKey: Keys.weeklyGoalSessions) }
    }

    @Published var weeklyGoalMinutes: Int {
        didSet { defaults.set(weeklyGoalMinutes, forKey: Keys.weeklyGoalMinutes) }
    }

    @Published var reminderEnabled: Bool {
        didSet { defaults.set(reminderEnabled, forKey: Keys.reminderEnabled) }
    }

    @Published var reminderHour: Int {
        didSet { defaults.set(reminderHour, forKey: Keys.reminderHour) }
    }

    @Published var reminderMinute: Int {
        didSet { defaults.set(reminderMinute, forKey: Keys.reminderMinute) }
    }

    @Published var dismissedReminderDate: String? {
        didSet {
            if let dismissedReminderDate {
                defaults.set(dismissedReminderDate, forKey: Keys.dismissedReminderDate)
            } else {
                defaults.removeObject(forKey: Keys.dismissedReminderDate)
            }
        }
    }

    @Published var pendingAchievementBanners: [AchievementDefinition] = []
    @Published var pendingWorkoutNote: PendingWorkoutNote?

    var totalWorkoutMinutes: Int { totalMinutesUsed }

    var activeRoutines: [ExerciseRoutine] {
        exerciseRoutines.filter { !$0.isArchived }
    }

    var archivedRoutines: [ExerciseRoutine] {
        exerciseRoutines.filter(\.isArchived)
    }

    var allTemplates: [IntervalTemplate] {
        IntervalTemplate.builtIn + customTemplates
    }

    var routinesCreatedCount: Int {
        exerciseRoutines.count
    }

    init() {
        let d = UserDefaults.standard
        hasSeenOnboarding = d.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = d.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = d.integer(forKey: Keys.totalMinutesUsed)
        streakDays = d.integer(forKey: Keys.streakDays)
        lastActivityDate = d.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadAchievements(from: d)
        workoutsCompleted = d.integer(forKey: Keys.workoutsCompleted)
        roundsCompleted = d.integer(forKey: Keys.roundsCompleted)
        longestSessionMinutes = d.integer(forKey: Keys.longestSessionMinutes)
        workSeconds = d.integer(forKey: Keys.workSeconds)
        restSeconds = d.integer(forKey: Keys.restSeconds)
        roundsCount = d.integer(forKey: Keys.roundsCount)
        timerConfigured = d.bool(forKey: Keys.timerConfigured)
        exerciseRoutines = Self.loadRoutines(from: d)
        completedExercises = Self.loadCompletedExercises(from: d)
        completedSessionsCount = d.integer(forKey: Keys.completedSessionsCount)
        totalMinutesWorkedOut = d.integer(forKey: Keys.totalMinutesWorkedOut)
        weeklyWorkoutData = Self.loadWeeklyData(from: d)
        entriesCreated = d.integer(forKey: Keys.entriesCreated)
        sessionHistory = Self.loadSessionHistory(from: d)
        customTemplates = Self.loadCustomTemplates(from: d)
        let loadedGoalSessions = d.integer(forKey: Keys.weeklyGoalSessions)
        weeklyGoalSessions = loadedGoalSessions > 0 ? loadedGoalSessions : 3
        let loadedGoalMinutes = d.integer(forKey: Keys.weeklyGoalMinutes)
        weeklyGoalMinutes = loadedGoalMinutes > 0 ? loadedGoalMinutes : 150
        reminderEnabled = d.bool(forKey: Keys.reminderEnabled)
        reminderHour = d.object(forKey: Keys.reminderHour) == nil ? 18 : d.integer(forKey: Keys.reminderHour)
        reminderMinute = d.object(forKey: Keys.reminderMinute) == nil ? 0 : d.integer(forKey: Keys.reminderMinute)
        dismissedReminderDate = d.string(forKey: Keys.dismissedReminderDate)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
    }

    // MARK: - Sessions

    func recordMeaningfulActivity() {
        updateStreak()
    }

    func recordWorkoutCompleted(
        minutes: Int,
        rounds: Int = 0,
        type: WorkoutSessionType,
        routineTitle: String? = nil,
        templateName: String? = nil,
        note: String = ""
    ) {
        workoutsCompleted += 1
        totalSessionsCompleted += 1
        completedSessionsCount += 1
        totalMinutesUsed += minutes
        totalMinutesWorkedOut += minutes
        if rounds > 0 { roundsCompleted += rounds }
        if minutes > longestSessionMinutes { longestSessionMinutes = minutes }
        addWeeklyMinutes(minutes)
        recordMeaningfulActivity()

        let record = WorkoutSessionRecord(
            sessionType: type,
            minutes: minutes,
            rounds: rounds,
            routineTitle: routineTitle,
            templateName: templateName,
            note: note
        )
        sessionHistory.insert(record, at: 0)
        AchievementManager.evaluate(store: self)
    }

    func recordTimerSessionCompleted(totalMinutes: Int, roundsFinished: Int, templateName: String?, note: String = "") {
        recordWorkoutCompleted(
            minutes: totalMinutes,
            rounds: roundsFinished,
            type: .timer,
            templateName: templateName,
            note: note
        )
    }

    func logManualWorkout(minutes: Int, note: String = "") {
        entriesCreated += 1
        recordWorkoutCompleted(minutes: max(minutes, 1), type: .manual, note: note)
    }

    func updateSessionNote(_ sessionId: UUID, note: String) {
        guard let index = sessionHistory.firstIndex(where: { $0.id == sessionId }) else { return }
        sessionHistory[index].note = note
    }

    func deleteSession(_ sessionId: UUID) {
        sessionHistory.removeAll { $0.id == sessionId }
    }

    // MARK: - Routines

    func addRoutine(_ routine: ExerciseRoutine) {
        exerciseRoutines.append(routine)
        entriesCreated += 1
        recordMeaningfulActivity()
        AchievementManager.evaluate(store: self)
    }

    func updateRoutine(_ routine: ExerciseRoutine) {
        if let index = exerciseRoutines.firstIndex(where: { $0.id == routine.id }) {
            exerciseRoutines[index] = routine
        }
    }

    func deleteRoutine(at offsets: IndexSet, from routines: [ExerciseRoutine]) {
        let idsToRemove = Set(offsets.compactMap { routines[$0].id })
        exerciseRoutines.removeAll { idsToRemove.contains($0.id) }
    }

    func duplicateRoutine(_ routine: ExerciseRoutine) {
        var copy = routine
        copy.id = UUID()
        copy.title = "\(routine.title) Copy"
        copy.exercises = routine.exercises.map {
            ExerciseItem(id: UUID(), name: $0.name, repsOrDuration: $0.repsOrDuration, restSeconds: $0.restSeconds)
        }
        copy.isArchived = false
        exerciseRoutines.append(copy)
        entriesCreated += 1
        FeedbackManager.mediumImpact()
    }

    func setRoutineArchived(_ routineId: UUID, archived: Bool) {
        guard let index = exerciseRoutines.firstIndex(where: { $0.id == routineId }) else { return }
        exerciseRoutines[index].isArchived = archived
    }

    func toggleExerciseComplete(_ exerciseId: UUID) {
        if completedExercises.contains(exerciseId) {
            completedExercises.remove(exerciseId)
        } else {
            completedExercises.insert(exerciseId)
            recordMeaningfulActivity()
        }
    }

    func allRoutineTags() -> [String] {
        Array(Set(activeRoutines.flatMap(\.tags))).sorted()
    }

    // MARK: - Templates

    func saveCustomTemplate(name: String, work: Int, rest: Int, rounds: Int) {
        let template = IntervalTemplate(name: name, workSeconds: work, restSeconds: rest, roundsCount: rounds)
        customTemplates.append(template)
        entriesCreated += 1
    }

    func deleteCustomTemplate(_ templateId: UUID) {
        customTemplates.removeAll { $0.id == templateId }
    }

    func applyTemplate(_ template: IntervalTemplate) {
        configureTimer(work: template.workSeconds, rest: template.restSeconds, rounds: template.roundsCount)
    }

    // MARK: - Timer

    func configureTimer(work: Int, rest: Int, rounds: Int) {
        workSeconds = work
        restSeconds = rest
        roundsCount = rounds
        timerConfigured = work > 0 && rest >= 0 && rounds > 0
    }

    var timerTotalDurationSeconds: Int {
        guard timerConfigured else { return 0 }
        return (workSeconds + restSeconds) * roundsCount - restSeconds
    }

    // MARK: - Analytics

    func minutesForDate(_ date: Date) -> Int {
        weeklyWorkoutData[Self.dateKey(date)] ?? 0
    }

    func sessionsForDate(_ date: Date) -> Int {
        let key = Self.dateKey(date)
        return sessionHistory.filter { Self.dateKey($0.date) == key }.count
    }

    func weekDays(reference: Date = Date()) -> [Date] {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: reference)?.start else {
            return []
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    func minutesThisWeek(reference: Date = Date()) -> Int {
        weekDays(reference: reference).reduce(0) { $0 + minutesForDate($1) }
    }

    func minutesLastWeek(reference: Date = Date()) -> Int {
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: reference) else { return 0 }
        return minutesThisWeek(reference: lastWeek)
    }

    func sessionsThisWeek(reference: Date = Date()) -> Int {
        let keys = Set(weekDays(reference: reference).map(Self.dateKey))
        return sessionHistory.filter { keys.contains(Self.dateKey($0.date)) }.count
    }

    func sessionsLastWeek(reference: Date = Date()) -> Int {
        guard let lastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: reference) else { return 0 }
        let keys = Set(weekDays(reference: lastWeek).map(Self.dateKey))
        return sessionHistory.filter { keys.contains(Self.dateKey($0.date)) }.count
    }

    func activeDaysThisWeek(reference: Date = Date()) -> Int {
        weekDays(reference: reference).filter { minutesForDate($0) > 0 }.count
    }

    func minutesToday() -> Int {
        minutesForDate(Date())
    }

    func trainedToday() -> Bool {
        let todayKey = Self.dateKey(Date())
        if minutesForDate(Date()) > 0 { return true }
        return sessionHistory.contains { Self.dateKey($0.date) == todayKey }
    }

    var weeklySessionProgress: Double {
        guard weeklyGoalSessions > 0 else { return 0 }
        return min(Double(sessionsThisWeek()) / Double(weeklyGoalSessions), 1)
    }

    var weeklyMinutesProgress: Double {
        guard weeklyGoalMinutes > 0 else { return 0 }
        return min(Double(minutesThisWeek()) / Double(weeklyGoalMinutes), 1)
    }

    func calendarDays(count: Int = 42, endingOn date: Date = Date()) -> [Date] {
        let end = calendar.startOfDay(for: date)
        return (0..<count).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: end)
        }.reversed()
    }

    // MARK: - Reminder

    func shouldShowInAppReminder() -> Bool {
        guard InAppReminderService.shouldShowReminder(store: self) else { return false }
        let today = Self.dateKey(Date())
        return dismissedReminderDate != today
    }

    func dismissInAppReminderForToday() {
        dismissedReminderDate = Self.dateKey(Date())
    }

    // MARK: - Reset

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier
        if let domain {
            defaults.removePersistentDomain(forName: domain)
        }
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    @objc private func handleDataReset() {
        reloadFromDefaults()
    }

    private func reloadFromDefaults() {
        let d = UserDefaults.standard
        hasSeenOnboarding = d.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = d.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = d.integer(forKey: Keys.totalMinutesUsed)
        streakDays = d.integer(forKey: Keys.streakDays)
        lastActivityDate = d.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadAchievements(from: d)
        workoutsCompleted = d.integer(forKey: Keys.workoutsCompleted)
        roundsCompleted = d.integer(forKey: Keys.roundsCompleted)
        longestSessionMinutes = d.integer(forKey: Keys.longestSessionMinutes)
        workSeconds = d.integer(forKey: Keys.workSeconds)
        restSeconds = d.integer(forKey: Keys.restSeconds)
        roundsCount = d.integer(forKey: Keys.roundsCount)
        timerConfigured = d.bool(forKey: Keys.timerConfigured)
        exerciseRoutines = Self.loadRoutines(from: d)
        completedExercises = Self.loadCompletedExercises(from: d)
        completedSessionsCount = d.integer(forKey: Keys.completedSessionsCount)
        totalMinutesWorkedOut = d.integer(forKey: Keys.totalMinutesWorkedOut)
        weeklyWorkoutData = Self.loadWeeklyData(from: d)
        entriesCreated = d.integer(forKey: Keys.entriesCreated)
        sessionHistory = Self.loadSessionHistory(from: d)
        customTemplates = Self.loadCustomTemplates(from: d)
        weeklyGoalSessions = max(d.integer(forKey: Keys.weeklyGoalSessions), 3)
        weeklyGoalMinutes = max(d.integer(forKey: Keys.weeklyGoalMinutes), 150)
        reminderEnabled = d.bool(forKey: Keys.reminderEnabled)
        reminderHour = d.object(forKey: Keys.reminderHour) == nil ? 18 : d.integer(forKey: Keys.reminderHour)
        reminderMinute = d.object(forKey: Keys.reminderMinute) == nil ? 0 : d.integer(forKey: Keys.reminderMinute)
        dismissedReminderDate = d.string(forKey: Keys.dismissedReminderDate)
        pendingAchievementBanners = []
        pendingWorkoutNote = nil
    }

    private func updateStreak() {
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today { return }
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               lastDay == yesterday {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func addWeeklyMinutes(_ minutes: Int) {
        let key = Self.dateKey(Date())
        weeklyWorkoutData[key, default: 0] += minutes
    }

    static func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private func saveAchievements() {
        if let data = try? JSONEncoder().encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private func saveRoutines() {
        if let data = try? JSONEncoder().encode(exerciseRoutines) {
            defaults.set(data, forKey: Keys.exerciseRoutines)
        }
    }

    private func saveCompletedExercises() {
        let ids = completedExercises.map { $0.uuidString }
        defaults.set(ids, forKey: Keys.completedExercises)
    }

    private func saveWeeklyData() {
        if let data = try? JSONEncoder().encode(weeklyWorkoutData) {
            defaults.set(data, forKey: Keys.weeklyWorkoutData)
        }
    }

    private func saveSessionHistory() {
        if let data = try? JSONEncoder().encode(sessionHistory) {
            defaults.set(data, forKey: Keys.sessionHistory)
        }
    }

    private func saveCustomTemplates() {
        if let data = try? JSONEncoder().encode(customTemplates) {
            defaults.set(data, forKey: Keys.customTemplates)
        }
    }

    private static func loadAchievements(from d: UserDefaults) -> [String: Date] {
        guard let data = d.data(forKey: Keys.achievementsUnlocked),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func loadRoutines(from d: UserDefaults) -> [ExerciseRoutine] {
        guard let data = d.data(forKey: Keys.exerciseRoutines),
              let decoded = try? JSONDecoder().decode([ExerciseRoutine].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func loadCompletedExercises(from d: UserDefaults) -> Set<UUID> {
        guard let strings = d.stringArray(forKey: Keys.completedExercises) else { return [] }
        return Set(strings.compactMap { UUID(uuidString: $0) })
    }

    private static func loadWeeklyData(from d: UserDefaults) -> [String: Int] {
        guard let data = d.data(forKey: Keys.weeklyWorkoutData),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func loadSessionHistory(from d: UserDefaults) -> [WorkoutSessionRecord] {
        guard let data = d.data(forKey: Keys.sessionHistory),
              let decoded = try? JSONDecoder().decode([WorkoutSessionRecord].self, from: data) else {
            return []
        }
        return decoded
    }

    private static func loadCustomTemplates(from d: UserDefaults) -> [IntervalTemplate] {
        guard let data = d.data(forKey: Keys.customTemplates),
              let decoded = try? JSONDecoder().decode([IntervalTemplate].self, from: data) else {
            return []
        }
        return decoded
    }
}

struct PendingWorkoutNote {
    let minutes: Int
    let rounds: Int
    let type: WorkoutSessionType
    let routineTitle: String?
    let templateName: String?
}
