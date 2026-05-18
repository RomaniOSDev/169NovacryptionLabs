import SwiftUI

// MARK: - Elevation (single shadow per surface — GPU-friendly)

enum AppElevation {
    case none
    case inset
    case card
    case raised
    case floating

    var shadowRadius: CGFloat {
        switch self {
        case .none, .inset: return 0
        case .card: return 10
        case .raised: return 14
        case .floating: return 18
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .none, .inset: return 0
        case .card: return 5
        case .raised: return 7
        case .floating: return 9
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .none, .inset: return 0
        case .card: return 0.32
        case .raised: return 0.38
        case .floating: return 0.45
        }
    }
}

// MARK: - Shared gradients (static — not recreated every frame)

enum AppGradients {
    static let surface = LinearGradient(
        colors: [
            Color.appSurfaceFallback.opacity(0.94),
            Color.appSurfaceFallback.opacity(0.72),
            Color.appBackgroundFallback.opacity(0.82)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let surfaceInset = LinearGradient(
        colors: [
            Color.appBackgroundFallback.opacity(0.42),
            Color.appBackgroundFallback.opacity(0.28)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let border = LinearGradient(
        colors: [Color.white.opacity(0.3), Color.white.opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let topSheen = LinearGradient(
        colors: [Color.white.opacity(0.16), Color.clear],
        startPoint: .top,
        endPoint: .center
    )

    static let primary = LinearGradient(
        colors: [Color.appPrimary, Color.appAccent.opacity(0.92)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGlow = LinearGradient(
        colors: [Color.appAccent.opacity(0.35), Color.clear],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )

    static let progress = LinearGradient(
        colors: [Color.appPrimary, Color.appAccent],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Elevated surface background

struct ElevatedSurfaceBackground: View {
    var cornerRadius: CGFloat
    var elevation: AppElevation
    var showAccentGlow: Bool = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Group {
            switch elevation {
            case .inset:
                shape.fill(AppGradients.surfaceInset)
            default:
                shape.fill(AppGradients.surface)
            }
        }
        .overlay {
            if showAccentGlow {
                shape.fill(AppGradients.accentGlow).blendMode(.plusLighter).opacity(0.55)
            }
        }
        .overlay(shape.fill(AppGradients.topSheen).allowsHitTesting(false))
        .overlay(shape.stroke(AppGradients.border, lineWidth: 1))
    }
}

// MARK: - Modifiers

private struct ElevatedSurfaceModifier: ViewModifier {
    var cornerRadius: CGFloat
    var elevation: AppElevation
    var showAccentGlow: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ElevatedSurfaceBackground(
                    cornerRadius: cornerRadius,
                    elevation: elevation,
                    showAccentGlow: showAccentGlow
                )
            )
            .modifier(ShadowModifier(elevation: elevation))
    }
}

private struct ShadowModifier: ViewModifier {
    let elevation: AppElevation

    @ViewBuilder
    func body(content: Content) -> some View {
        if elevation == .none || elevation == .inset {
            content
        } else {
            content
                .compositingGroup()
                .shadow(
                    color: Color.appBackgroundFallback.opacity(elevation.shadowOpacity),
                    radius: elevation.shadowRadius,
                    y: elevation.shadowY
                )
        }
    }
}

extension View {
    func appElevatedSurface(
        cornerRadius: CGFloat = AppDesign.cornerRadius,
        elevation: AppElevation = .card,
        showAccentGlow: Bool = false
    ) -> some View {
        modifier(ElevatedSurfaceModifier(
            cornerRadius: cornerRadius,
            elevation: elevation,
            showAccentGlow: showAccentGlow
        ))
    }

    func appInsetPanel(cornerRadius: CGFloat = AppDesign.smallRadius) -> some View {
        appElevatedSurface(cornerRadius: cornerRadius, elevation: .inset)
    }
}
