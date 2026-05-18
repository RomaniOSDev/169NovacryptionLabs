import Foundation

struct IntervalTemplate: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var workSeconds: Int
    var restSeconds: Int
    var roundsCount: Int
    var isBuiltIn: Bool

    init(
        id: UUID = UUID(),
        name: String,
        workSeconds: Int,
        restSeconds: Int,
        roundsCount: Int,
        isBuiltIn: Bool = false
    ) {
        self.id = id
        self.name = name
        self.workSeconds = workSeconds
        self.restSeconds = restSeconds
        self.roundsCount = roundsCount
        self.isBuiltIn = isBuiltIn
    }

    static let builtIn: [IntervalTemplate] = [
        IntervalTemplate(name: "Tabata", workSeconds: 20, restSeconds: 10, roundsCount: 8, isBuiltIn: true),
        IntervalTemplate(name: "HIIT", workSeconds: 40, restSeconds: 20, roundsCount: 10, isBuiltIn: true),
        IntervalTemplate(name: "EMOM", workSeconds: 60, restSeconds: 0, roundsCount: 10, isBuiltIn: true)
    ]
}
