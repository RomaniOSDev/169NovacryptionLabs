import Foundation

struct ExerciseItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var repsOrDuration: String
    var restSeconds: Int

    init(id: UUID = UUID(), name: String = "", repsOrDuration: String = "", restSeconds: Int = 60) {
        self.id = id
        self.name = name
        self.repsOrDuration = repsOrDuration
        self.restSeconds = restSeconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        repsOrDuration = try container.decode(String.self, forKey: .repsOrDuration)
        restSeconds = try container.decodeIfPresent(Int.self, forKey: .restSeconds) ?? 60
    }

    var workSecondsEstimate: Int {
        let trimmed = repsOrDuration.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = trimmed.lowercased()
        let digits = trimmed.filter(\.isNumber)

        if lower.contains("min"), let value = Int(digits), value > 0 {
            return value * 60
        }
        if lower.contains("sec"), let value = Int(digits), value > 0 {
            return value
        }
        if let value = Int(digits), value > 0 {
            if value > 180 { return 60 }
            return value
        }
        return 45
    }
}
