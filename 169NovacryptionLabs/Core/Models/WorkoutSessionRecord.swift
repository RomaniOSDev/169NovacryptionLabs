import Foundation

enum WorkoutSessionType: String, Codable {
    case timer
    case manual
    case routine
}

struct WorkoutSessionRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var sessionType: WorkoutSessionType
    var minutes: Int
    var rounds: Int
    var routineTitle: String?
    var templateName: String?
    var note: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        sessionType: WorkoutSessionType,
        minutes: Int,
        rounds: Int = 0,
        routineTitle: String? = nil,
        templateName: String? = nil,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.sessionType = sessionType
        self.minutes = minutes
        self.rounds = rounds
        self.routineTitle = routineTitle
        self.templateName = templateName
        self.note = note
    }

    var typeLabel: String {
        switch sessionType {
        case .timer: return templateName ?? "Interval Timer"
        case .manual: return "Manual Log"
        case .routine: return routineTitle ?? "Routine"
        }
    }
}
