import Foundation

struct ExerciseRoutine: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var exercises: [ExerciseItem]
    var tags: [String]
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        title: String = "",
        exercises: [ExerciseItem] = [],
        tags: [String] = [],
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.exercises = exercises
        self.tags = tags
        self.isArchived = isArchived
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        exercises = try container.decode([ExerciseItem].self, forKey: .exercises)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        isArchived = try container.decodeIfPresent(Bool.self, forKey: .isArchived) ?? false
    }
}
