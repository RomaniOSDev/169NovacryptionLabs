import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_steps", title: "First Steps", description: "Completed the first workout.", systemImage: "figure.walk"),
        AchievementDefinition(id: "consistent_user", title: "Consistent User", description: "Worked out for three consecutive days.", systemImage: "calendar"),
        AchievementDefinition(id: "minute_milestone", title: "Minute Milestone", description: "Achieved 100 minutes of total workout time.", systemImage: "clock.fill"),
        AchievementDefinition(id: "five_sessions", title: "+5 Sessions", description: "+5 distinct workout sessions completed.", systemImage: "5.circle.fill"),
        AchievementDefinition(id: "ten_rounds", title: "+10 Rounds Completed", description: "+10 rounds finished in all exercises combined.", systemImage: "repeat.circle.fill"),
        AchievementDefinition(id: "extended_session", title: "Extended Session", description: "Longest session lasts at least one hour.", systemImage: "hourglass"),
        AchievementDefinition(id: "seven_days", title: "+7 Consecutive Days", description: "Seven or more consecutive days of working out.", systemImage: "flame.fill"),
        AchievementDefinition(id: "getting_going", title: "Getting Going", description: "Reached 10 items.", systemImage: "star.fill"),
        AchievementDefinition(id: "thirty_day_streak", title: "30-Day Streak", description: "Maintained a 30-day workout streak.", systemImage: "flame.circle.fill"),
        AchievementDefinition(id: "five_hundred_minutes", title: "500 Minutes", description: "Logged 500 total workout minutes.", systemImage: "timer.circle.fill"),
        AchievementDefinition(id: "routine_builder", title: "Routine Builder", description: "Created 20 exercise routines.", systemImage: "list.bullet.rectangle.fill")
    ]
}
