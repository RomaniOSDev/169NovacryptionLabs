import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            Color.appBackgroundFallback

            LinearGradient(
                colors: [
                    Color.appBackgroundFallback,
                    Color.appSurfaceFallback.opacity(0.85),
                    Color.appBackgroundFallback
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.appPrimary.opacity(0.26), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 300
            )

            RadialGradient(
                colors: [Color.appAccent.opacity(0.18), Color.clear],
                center: .bottomLeading,
                startRadius: 24,
                endRadius: 260
            )

            BackgroundDecorLayer()
                .drawingGroup(opaque: false)

            LinearGradient(
                colors: [
                    Color.appBackgroundFallback.opacity(0.12),
                    Color.clear,
                    Color.appBackgroundFallback.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

private struct BackgroundDecorLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                BackgroundWaveLayer()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurfaceFallback.opacity(0.4),
                                Color.appBackgroundFallback.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                BackgroundRingsLayer()
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)

                CanvasDotPattern()
                    .opacity(0.16)
            }
            .frame(width: size.width, height: size.height)
        }
    }
}

private struct BackgroundWaveLayer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.62))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.72),
            control1: CGPoint(x: w * 0.28, y: h * 0.52),
            control2: CGPoint(x: w * 0.72, y: h * 0.88)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.addLine(to: CGPoint(x: 0, y: h))
        path.closeSubpath()
        return path
    }
}

private struct BackgroundRingsLayer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width * 0.82, y: rect.height * 0.22)
        for radius in stride(from: 50.0, through: 150.0, by: 50) {
            path.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            ))
        }
        return path
    }
}

/// Sparse static dots — drawn once via parent `drawingGroup`.
private struct CanvasDotPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 42
            var x: CGFloat = spacing * 0.5
            while x < size.width {
                var y: CGFloat = spacing * 0.5
                while y < size.height {
                    let rect = CGRect(x: x, y: y, width: 2.5, height: 2.5)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.5)))
                    y += spacing
                }
                x += spacing
            }
        }
    }
}

struct AppScreenContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            AppBackgroundView()
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
        }
    }
}

struct AppNavigationShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
        .background(Color.clear)
    }
}

extension View {
    func appScreenStyle() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.clear)
    }

    func appRootBackground() -> some View {
        ZStack {
            AppBackgroundView()
            self
                .background(Color.clear)
        }
    }
}
