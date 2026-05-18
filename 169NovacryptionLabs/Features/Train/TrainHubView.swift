import SwiftUI

struct TrainHubView: View {
    @Binding var segment: Int

    private let segments = ["Routines", "Progress", "History"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                VStack(spacing: 0) {
                    segmentControl
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    Group {
                        switch segment {
                        case 0:
                            RoutinesView()
                        case 1:
                            ProgressOverviewView()
                        default:
                            SessionHistoryView()
                        }
                    }
                    .background(Color.clear)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
        .background(Color.clear)
    }

    private var segmentControl: some View {
        HStack(spacing: 6) {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, title in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        segment = index
                    }
                } label: {
                    Text(title)
                        .font(.subheadline.weight(segment == index ? .bold : .medium))
                        .foregroundStyle(segment == index ? Color.appBackgroundFallback : Color.appTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(segmentBackground(isSelected: segment == index))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .appInsetPanel(cornerRadius: 22)
    }

    @ViewBuilder
    private func segmentBackground(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(AppGradients.primary)
                .overlay(Capsule().fill(AppGradients.topSheen))
                .compositingGroup()
                .shadow(color: Color.appPrimary.opacity(0.3), radius: 6, y: 2)
        } else {
            Capsule().fill(Color.clear)
        }
    }

    private var navigationTitle: String {
        switch segment {
        case 0: return "Your Exercise Routines"
        case 1: return "Progress Overview"
        default: return "Session History"
        }
    }
}
