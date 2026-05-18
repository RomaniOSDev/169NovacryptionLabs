import Foundation

enum RoutineTag: String, CaseIterable, Identifiable {
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case cardio = "Cardio"
    case core = "Core"
    case fullBody = "Full Body"
    case flexibility = "Flexibility"

    var id: String { rawValue }
}
