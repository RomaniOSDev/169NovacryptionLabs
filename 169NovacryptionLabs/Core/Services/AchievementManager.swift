import Foundation

enum AchievementManager {
    static func evaluate(store: AppDataStore) {
        var newlyUnlocked: [AchievementDefinition] = []

        for achievement in AchievementDefinition.all {
            guard store.achievementsUnlocked[achievement.id] == nil else { continue }
            if isUnlocked(achievement, store: store) {
                store.achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }

        guard !newlyUnlocked.isEmpty else { return }

        for achievement in newlyUnlocked {
            FeedbackManager.success()
            if !store.pendingAchievementBanners.contains(where: { $0.id == achievement.id }) {
                store.pendingAchievementBanners.append(achievement)
            }
        }
    }

    static func isUnlocked(_ achievement: AchievementDefinition, store: AppDataStore) -> Bool {
        if store.achievementsUnlocked[achievement.id] != nil { return true }
        switch achievement.id {
        case "first_steps":
            return store.workoutsCompleted >= 1
        case "consistent_user":
            return store.streakDays >= 3
        case "minute_milestone":
            return store.totalWorkoutMinutes >= 100
        case "five_sessions":
            return store.workoutsCompleted >= 5
        case "ten_rounds":
            return store.roundsCompleted >= 10
        case "extended_session":
            return store.longestSessionMinutes >= 60
        case "seven_days":
            return store.streakDays >= 7
        case "getting_going":
            return store.workoutsCompleted >= 10
        case "thirty_day_streak":
            return store.streakDays >= 30
        case "five_hundred_minutes":
            return store.totalWorkoutMinutes >= 500
        case "routine_builder":
            return store.routinesCreatedCount >= 20
        default:
            return false
        }
    }
}
