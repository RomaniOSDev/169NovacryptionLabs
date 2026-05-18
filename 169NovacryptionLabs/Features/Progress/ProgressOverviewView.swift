import SwiftUI

struct ProgressOverviewView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: AppDesign.sectionSpacing) {
                    AppWeekNavigator(
                        title: viewModel.weekTitle(store: store),
                        onPrevious: {
                            withAnimation(.easeInOut(duration: 0.3)) { viewModel.weekOffset -= 1 }
                        },
                        onNext: {
                            withAnimation(.easeInOut(duration: 0.3)) { viewModel.weekOffset += 1 }
                        }
                    )

                    if viewModel.hasWeekData(store: store) {
                        WeeklyBarChartView(data: viewModel.barData(store: store))
                            .frame(height: 210)
                            .gesture(weekSwipeGesture)
                    } else {
                        emptyChart
                    }

                    WeeklyGoalsCardView()
                    WeekComparisonCardView()
                    ActivityCalendarView()
                    summarySection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 88)
            }
            .appScreenStyle()

            AppFloatingButton(icon: "plus") {
                viewModel.showLogSheet = true
            }
            .padding(20)
        }
        .sheet(isPresented: $viewModel.showLogSheet) { logWorkoutSheet }
        .sheet(isPresented: $viewModel.showNoteSheet) {
            WorkoutNoteSheet(
                title: "Log Workout",
                note: $viewModel.workoutNote,
                onSave: { viewModel.saveLoggedWorkout(store: store) },
                onSkip: { viewModel.saveLoggedWorkout(store: store, skipNote: true) }
            )
        }
        .overlay {
            SuccessCheckmarkOverlay(isVisible: $viewModel.showSuccess)
        }
    }

    private var weekSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                if value.translation.width < -40 {
                    FeedbackManager.lightTap()
                    viewModel.weekOffset += 1
                } else if value.translation.width > 40 {
                    FeedbackManager.lightTap()
                    viewModel.weekOffset -= 1
                }
            }
    }

    private var emptyChart: some View {
        AppEmptyState(
            icon: "flame.fill",
            title: store.completedSessionsCount == 0 ? "No Data Yet" : "No Workouts This Week",
            message: store.completedSessionsCount == 0
                ? "Start your first workout to see progress here."
                : "No workouts logged this week. Tap + to add one.",
            buttonTitle: "Log Workout",
            action: { viewModel.showLogSheet = true }
        )
    }

    private var summarySection: some View {
        AppGlassCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(title: "Lifetime Summary")
                HStack(spacing: 12) {
                    AppStatTile(icon: "checkmark.circle.fill", title: "Sessions", value: "\(store.completedSessionsCount)")
                    AppStatTile(icon: "clock.fill", title: "Minutes", value: "\(store.totalMinutesWorkedOut)")
                }
            }
        }
    }

    private var logWorkoutSheet: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 16) {
                    AppStepperCell(
                        title: "Minutes",
                        icon: "plus.circle.fill",
                        value: $viewModel.logMinutes,
                        range: 1...600,
                        errorText: viewModel.minutesError,
                        shakeTrigger: viewModel.shakeTrigger
                    )
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Log Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        viewModel.showLogSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        viewModel.logWorkout(store: store)
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private struct WeeklyBarChartView: View {
    let data: [(label: String, minutes: Int)]

    private var maxVal: Int { max(data.map(\.minutes).max() ?? 1, 1) }

    var body: some View {
        AppGlassCard {
            VStack(spacing: 12) {
                AppSectionHeader(title: "Weekly Chart", subtitle: "Minutes per day")
                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: geo.size.width / CGFloat(max(data.count, 1)) * 0.2) {
                        ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(AppGradients.progress)
                                    .frame(
                                        height: max(
                                            CGFloat(item.minutes) / CGFloat(maxVal) * (geo.size.height - 28),
                                            item.minutes > 0 ? 6 : 2
                                        )
                                    )
                                Text(item.label)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 160)
            }
        }
    }
}
