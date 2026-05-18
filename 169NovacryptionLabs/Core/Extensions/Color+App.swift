import SwiftUI

extension Color {
    // Fallback RGB matches Assets.xcassets — always visible even if catalog fails to load.
    static let appBackground = Color("AppBackground", bundle: .main)
    static let appSurface = Color("AppSurface", bundle: .main)
    static let appPrimary = Color("AppPrimary", bundle: .main)
    static let appAccent = Color("AppAccent", bundle: .main)
    static let appTextPrimary = Color("AppTextPrimary", bundle: .main)
    static let appTextSecondary = Color("AppTextSecondary", bundle: .main)

    static let appBackgroundFallback = Color(red: 85 / 255, green: 168 / 255, blue: 192 / 255)
    static let appSurfaceFallback = Color(red: 105 / 255, green: 178 / 255, blue: 200 / 255)
}
