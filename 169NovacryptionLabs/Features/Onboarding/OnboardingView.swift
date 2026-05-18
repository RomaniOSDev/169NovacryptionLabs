import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "bolt.fill",
            stepLabel: "Welcome",
            headline: "Get Started",
            description: "Your training hub for timers, routines, and progress — all in one place.",
            highlights: [
                ("house.fill", "Home dashboard"),
                ("chart.bar.fill", "Weekly insights"),
                ("flame.fill", "Streak tracking")
            ]
        ),
        OnboardingPage(
            icon: "timer",
            stepLabel: "Timer",
            headline: "Use The Timer",
            description: "Run interval sessions with presets like Tabata and HIIT, or build your own work and rest cycles.",
            highlights: [
                ("flame.fill", "Work intervals"),
                ("pause.fill", "Rest periods"),
                ("note.text", "Session notes")
            ]
        ),
        OnboardingPage(
            icon: "dumbbell.fill",
            stepLabel: "Train",
            headline: "Plan Your Routine",
            description: "Create exercise lists, set rest between moves, and play guided routine sessions.",
            highlights: [
                ("list.bullet.rectangle", "Custom routines"),
                ("play.fill", "Guided player"),
                ("clock.fill", "Per-exercise rest")
            ]
        )
    ]

    var body: some View {
        AppScreenContainer {
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        OnboardingPageContent(page: item, pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: page)

                pageIndicator
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                bottomActions
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("Step \(page + 1) of \(pages.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            if page < pages.count - 1 {
                Button("Skip") {
                    FeedbackManager.lightTap()
                    completeOnboarding()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
                .frame(minHeight: 44)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let progress = CGFloat(page + 1) / CGFloat(pages.count)
            Capsule()
                .fill(Color.appBackgroundFallback.opacity(0.45))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(AppGradients.progress)
                        .frame(width: max(geo.size.width * progress, 12))
                }
        }
        .frame(height: 6)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? AnyShapeStyle(AppGradients.primary) : AnyShapeStyle(Color.appTextPrimary.opacity(0.22)))
                    .frame(width: index == page ? 28 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: page)
            }
        }
    }

    private var bottomActions: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: page < pages.count - 1 ? "Continue" : "Get Started") {
                if page < pages.count - 1 {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page += 1
                    }
                } else {
                    completeOnboarding()
                }
            }

            if page > 0 {
                Button("Back") {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        page -= 1
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(minHeight: 44)
            }
        }
    }

    private func completeOnboarding() {
        FeedbackManager.mediumImpact()
        store.hasSeenOnboarding = true
    }
}

// MARK: - Page model

private struct OnboardingPage {
    let icon: String
    let stepLabel: String
    let headline: String
    let description: String
    let highlights: [(icon: String, title: String)]
}

// MARK: - Page content

private struct OnboardingPageContent: View {
    let page: OnboardingPage
    let pageIndex: Int

    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppDesign.sectionSpacing) {
                AppGlassCard(accentGlow: true) {
                    VStack(spacing: 22) {
                        iconHero
                        VStack(spacing: 10) {
                            Text(page.stepLabel.uppercased())
                                .font(.caption.weight(.heavy))
                                .foregroundStyle(Color.appAccent)
                                .tracking(1.2)
                            Text(page.headline)
                                .font(.title.bold())
                                .foregroundStyle(Color.appTextPrimary)
                                .multilineTextAlignment(.center)
                            Text(page.description)
                                .font(.body)
                                .foregroundStyle(Color.appTextSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                AppGlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionHeader(title: "What you can do", subtitle: "Key features on this step")
                        VStack(spacing: 10) {
                            ForEach(Array(page.highlights.enumerated()), id: \.offset) { index, item in
                                highlightRow(icon: item.icon, title: item.title, index: index)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .onAppear {
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                appeared = true
            }
        }
        .onChange(of: pageIndex) { _ in
            appeared = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    private var iconHero: some View {
        ZStack {
            Circle()
                .stroke(Color.appBackgroundFallback.opacity(0.35), lineWidth: 10)
                .frame(width: 132, height: 132)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(AppGradients.progress, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 132, height: 132)
                .rotationEffect(.degrees(-90))
            AppIconBadge(
                systemName: page.icon,
                size: 80,
                tint: .appAccent,
                background: Color.appPrimary.opacity(0.22)
            )
            .scaleEffect(appeared ? 1 : 0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private func highlightRow(icon: String, title: String, index: Int) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppGradients.primary)
                    .frame(width: 26, height: 26)
                Text("\(index + 1)")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(Color.appBackgroundFallback)
            }
            AppIconBadge(systemName: icon, size: 38, tint: .appPrimary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.appAccent.opacity(0.85))
        }
        .padding(12)
        .appInsetPanel(cornerRadius: AppDesign.smallRadius)
    }
}
