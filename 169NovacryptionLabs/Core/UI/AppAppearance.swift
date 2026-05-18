import UIKit

enum AppAppearance {
    private static var backgroundUIColor: UIColor {
        UIColor(red: 85 / 255, green: 168 / 255, blue: 192 / 255, alpha: 1)
    }

    private static var surfaceUIColor: UIColor {
        UIColor(red: 105 / 255, green: 178 / 255, blue: 200 / 255, alpha: 1)
    }

    static func configure() {
        let primary = UIColor(named: "AppTextPrimary") ?? .white
        let background = UIColor(named: "AppBackground") ?? backgroundUIColor
        let surface = UIColor(named: "AppSurface") ?? surfaceUIColor
        let accent = UIColor(named: "AppPrimary") ?? UIColor(red: 0.96, green: 0.73, blue: 0.04, alpha: 1)

        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = background
        navigation.shadowColor = .clear
        navigation.titleTextAttributes = [.foregroundColor: primary]
        navigation.largeTitleTextAttributes = [.foregroundColor: primary]

        let bar = UINavigationBar.appearance()
        bar.standardAppearance = navigation
        bar.scrollEdgeAppearance = navigation
        bar.compactAppearance = navigation
        bar.tintColor = accent
        bar.isTranslucent = false

        UITableView.appearance().backgroundColor = background
        UITableViewCell.appearance().backgroundColor = surface.withAlphaComponent(0.55)

        UICollectionView.appearance().backgroundColor = background
        UIScrollView.appearance().backgroundColor = background

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = primary

        let sectionHeader = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        sectionHeader.textColor = primary.withAlphaComponent(0.85)

        UITextField.appearance().textColor = primary
        UITextField.appearance().backgroundColor = surface.withAlphaComponent(0.35)

        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: primary],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: background],
            for: .selected
        )
        UISegmentedControl.appearance().selectedSegmentTintColor = accent
        UISegmentedControl.appearance().backgroundColor = surface.withAlphaComponent(0.5)

        applyWindowBackground()
    }

    static func applyWindowBackground() {
        let background = UIColor(named: "AppBackground") ?? backgroundUIColor
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { window in
                window.backgroundColor = background
                window.overrideUserInterfaceStyle = .dark
            }
    }
}
