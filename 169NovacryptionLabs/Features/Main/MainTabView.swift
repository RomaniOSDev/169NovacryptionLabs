import SwiftUI

enum MainTab: Int, CaseIterable {
    case home, timer, train, settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .timer: return "Timer"
        case .train: return "Train"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .timer: return "timer"
        case .train: return "figure.strengthtraining.traditional"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home
    @State private var trainSegment = 0

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView(selectedTab: $selectedTab, trainSegment: $trainSegment)
                    case .timer:
                        TimerView()
                    case .train:
                        TrainHubView(segment: $trainSegment)
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)

                CustomTabBar(selectedTab: $selectedTab)
            }

            if let banner = store.pendingAchievementBanners.first {
                AchievementBannerView(achievement: banner) {
                    if !store.pendingAchievementBanners.isEmpty {
                        store.pendingAchievementBanners.removeFirst()
                    }
                }
                .padding(.top, 8)
                .zIndex(10)
            }

            if store.shouldShowInAppReminder() {
                inAppReminderBanner
                    .padding(.top, store.pendingAchievementBanners.isEmpty ? 8 : 72)
                    .zIndex(9)
            }
        }
        .background(Color.clear)
    }

    private var inAppReminderBanner: some View {
        AppGlassCard(padding: 14) {
            HStack(spacing: 12) {
                AppIconBadge(systemName: "bell.fill", size: 40, tint: .appPrimary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Workout Reminder")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("You have not trained today. Start a quick session.")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
                Button {
                    FeedbackManager.lightTap()
                    store.dismissInAppReminderForToday()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MainTab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppGradients.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(AppGradients.topSheen)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppGradients.border, lineWidth: 1)
                )
                .compositingGroup()
                .shadow(color: Color.appBackgroundFallback.opacity(0.5), radius: 18, y: -6)
                .ignoresSafeArea(edges: .bottom)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            FeedbackManager.lightTap()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .medium))
                Text(tab.title)
                    .font(.caption2.weight(isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundStyle(isSelected ? Color.appBackgroundFallback : Color.appTextPrimary.opacity(0.75))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppGradients.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppGradients.topSheen)
                            )
                            .compositingGroup()
                            .shadow(color: Color.appPrimary.opacity(0.35), radius: 8, y: 3)
                    }
                }
            )
            .frame(minHeight: 52)
        }
        .buttonStyle(TabPressStyle())
    }
}

private struct TabPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: configuration.isPressed)
    }
}
