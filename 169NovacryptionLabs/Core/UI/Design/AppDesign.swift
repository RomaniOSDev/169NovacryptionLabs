import SwiftUI

enum AppDesign {
    static let cornerRadius: CGFloat = 18
    static let smallRadius: CGFloat = 12
    static let cellPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
}

// MARK: - Card shell

struct AppGlassCard<Content: View>: View {
    var padding: CGFloat = AppDesign.cellPadding
    var elevation: AppElevation = .card
    var accentGlow: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appElevatedSurface(
                cornerRadius: AppDesign.cornerRadius,
                elevation: elevation,
                showAccentGlow: accentGlow
            )
    }
}

// MARK: - Icon badge

struct AppIconBadge: View {
    let systemName: String
    var size: CGFloat = 44
    var tint: Color = .appPrimary
    var background: Color = Color.appPrimary.opacity(0.18)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [background.opacity(1.15), background.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(tint)
        }
        .compositingGroup()
        .shadow(color: tint.opacity(0.28), radius: 4, y: 2)
    }
}

// MARK: - Section header

struct AppSectionHeader: View {
    let title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle) {
                    FeedbackManager.lightTap()
                    action()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            }
        }
    }
}

// MARK: - Empty state

struct AppEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        AppGlassCard {
            VStack(spacing: 16) {
                AppIconBadge(systemName: icon, size: 64, tint: .appAccent, background: Color.appAccent.opacity(0.2))
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
                if let buttonTitle, let action {
                    PrimaryButton(title: buttonTitle, action: action)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Chip

struct AppChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? Color.appBackgroundFallback : Color.appTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(chipBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var chipBackground: some View {
        if isSelected {
            Capsule()
                .fill(AppGradients.primary)
                .overlay(Capsule().fill(AppGradients.topSheen))
                .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
                .compositingGroup()
                .shadow(color: Color.appPrimary.opacity(0.35), radius: 6, y: 3)
        } else {
            Capsule()
                .fill(AppGradients.surfaceInset)
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

// MARK: - Stat tile

struct AppStatTile: View {
    let icon: String
    let title: String
    let value: String
    var accent: Color = .appAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AppIconBadge(systemName: icon, size: 36, tint: accent, background: accent.opacity(0.2))
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appInsetPanel(cornerRadius: AppDesign.smallRadius)
    }
}

// MARK: - Settings / action row

struct AppActionRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    var tint: Color = .appPrimary
    var showsChevron: Bool = true
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                AppIconBadge(
                    systemName: icon,
                    size: 40,
                    tint: isDestructive ? .red : tint,
                    background: (isDestructive ? Color.red : tint).opacity(0.18)
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(isDestructive ? .red : Color.appTextPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(minHeight: 56)
    }
}

// MARK: - Stepper cell

struct AppStepperCell: View {
    let title: String
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var errorText: String?
    var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AppIconBadge(systemName: icon, size: 38, tint: .appPrimary)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }
            HStack(spacing: 0) {
                stepButton("minus") {
                    if value > range.lowerBound { value -= 1 }
                }
                Text("\(value)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .frame(maxWidth: .infinity)
                stepButton("plus") {
                    if value < range.upperBound { value += 1 }
                }
            }
            .padding(8)
            .appInsetPanel(cornerRadius: AppDesign.smallRadius)
            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .shake(trigger: shakeTrigger)
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: symbol)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.appPrimary.opacity(0.35), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template card

struct AppTemplateCard: View {
    let template: IntervalTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(template.name)
                        .font(.subheadline.weight(.bold))
                    if template.isBuiltIn {
                        Text("PRESET")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(Color.appBackgroundFallback)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.appAccent)
                            .clipShape(Capsule())
                    }
                }
                Label("\(template.workSeconds)s work", systemImage: "flame.fill")
                Label("\(template.restSeconds)s rest", systemImage: "pause.fill")
                Label("\(template.roundsCount) rounds", systemImage: "repeat")
            }
            .font(.caption)
            .foregroundStyle(Color.appTextPrimary)
            .frame(width: 148, alignment: .leading)
            .padding(14)
            .background(templateBackground)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var templateBackground: some View {
        let shape = RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
        if isSelected {
            shape
                .fill(Color.appPrimary.opacity(0.22))
                .overlay(shape.fill(AppGradients.primary))
                .overlay(shape.stroke(Color.appPrimary, lineWidth: 2))
                .overlay(shape.fill(AppGradients.topSheen).opacity(0.45))
                .compositingGroup()
                .shadow(color: Color.appPrimary.opacity(0.3), radius: 8, y: 4)
        } else {
            shape
                .fill(AppGradients.surfaceInset)
                .overlay(shape.stroke(Color.white.opacity(0.1), lineWidth: 1))
        }
    }
}

// MARK: - Session cell

struct AppSessionCell: View {
    let session: WorkoutSessionRecord
    let dateText: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                AppIconBadge(
                    systemName: iconName,
                    size: 48,
                    tint: .appPrimary,
                    background: Color.appPrimary.opacity(0.2)
                )
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.typeLabel)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(dateText)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    if !session.note.isEmpty {
                        Text(session.note)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 8)
                VStack(spacing: 4) {
                    Text("\(session.minutes)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.appAccent)
                    Text("min")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch session.sessionType {
        case .timer: return "timer"
        case .manual: return "plus.circle.fill"
        case .routine: return "figure.strengthtraining.traditional"
        }
    }
}

// MARK: - Exercise cell

struct AppExerciseCell: View {
    let name: String
    let detail: String
    let restText: String
    let isDone: Bool
    let isPulsing: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            onToggle()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isDone ? Color.appAccent : Color.appTextSecondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isDone {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.appBackgroundFallback)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.appAccent))
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .strikethrough(isDone)
                    HStack(spacing: 8) {
                        if !detail.isEmpty {
                            Label(detail, systemImage: "figure.walk")
                        }
                        Label(restText, systemImage: "pause.circle")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
            }
            .padding(14)
            .background { exerciseCellBackground }
            .overlay(
                RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                    .stroke(isDone ? Color.appAccent.opacity(0.55) : Color.white.opacity(0.08), lineWidth: 1)
            )
            .scaleEffect(isPulsing ? 1.02 : 1)
            .animation(.easeOut(duration: 0.2), value: isPulsing)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var exerciseCellBackground: some View {
        let shape = RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
        if isPulsing {
            shape.fill(AppGradients.accentGlow)
        } else {
            shape.fill(AppGradients.surfaceInset)
        }
    }
}

// MARK: - Routine card

struct AppRoutineCard: View {
    let routine: ExerciseRoutine
    let progress: Double
    let onStart: () -> Void
    let onEdit: () -> Void
    let exerciseContent: () -> AnyView

    init(
        routine: ExerciseRoutine,
        progress: Double,
        onStart: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        @ViewBuilder exerciseContent: @escaping () -> some View
    ) {
        self.routine = routine
        self.progress = progress
        self.onStart = onStart
        self.onEdit = onEdit
        self.exerciseContent = { AnyView(exerciseContent()) }
    }

    var body: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    progressRing
                    VStack(alignment: .leading, spacing: 6) {
                        Text(routine.title)
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        if !routine.tags.isEmpty {
                            Text(routine.tags.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        Text("\(routine.exercises.count) exercises")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appAccent)
                    }
                    Spacer()
                    Button {
                        FeedbackManager.lightTap()
                        onEdit()
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appPrimary)
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    FeedbackManager.lightTap()
                    onStart()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Routine")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(Color.appBackgroundFallback)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                            .fill(AppGradients.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                                    .fill(AppGradients.topSheen)
                            )
                    )
                    .compositingGroup()
                    .shadow(color: Color.appPrimary.opacity(0.38), radius: 8, y: 4)
                }
                .buttonStyle(.plain)

                exerciseContent()
            }
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.appBackgroundFallback.opacity(0.4), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AppGradients.progress,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
        }
        .frame(width: 52, height: 52)
    }
}

// MARK: - Week navigator

struct AppWeekNavigator: View {
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        AppGlassCard(padding: 12) {
            HStack {
                navButton("chevron.left", action: onPrevious)
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                navButton("chevron.right", action: onNext)
            }
        }
    }

    private func navButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.body.weight(.bold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.appPrimary.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.appPrimary.opacity(0.35), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FAB

struct AppFloatingButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.appBackgroundFallback)
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(AppGradients.primary)
                        .overlay(Circle().fill(AppGradients.topSheen))
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                )
        }
        .buttonStyle(.plain)
        .compositingGroup()
        .shadow(color: Color.appPrimary.opacity(0.45), radius: 12, y: 5)
    }
}

// MARK: - Progress row

struct AppProgressRow: View {
    let title: String
    let valueText: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                Spacer()
                Text(valueText)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            Capsule()
                .fill(Color.appBackgroundFallback.opacity(0.4))
                .overlay(alignment: .leading) {
                    GeometryReader { geo in
                        Capsule()
                            .fill(AppGradients.progress)
                            .frame(width: max(geo.size.width * progress, progress > 0 ? 8 : 0))
                    }
                }
                .frame(height: 8)
                .clipShape(Capsule())
        }
    }
}

// MARK: - View extensions

extension View {
    func appCardStyle() -> some View {
        self
            .padding(AppDesign.cellPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appElevatedSurface(cornerRadius: AppDesign.cornerRadius, elevation: .card)
    }
}
