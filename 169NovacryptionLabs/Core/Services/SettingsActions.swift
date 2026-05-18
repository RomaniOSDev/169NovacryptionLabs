import StoreKit
import UIKit

enum SettingsActions {
    static func open(_ link: AppExternalLink) {
        guard let url = link.url else { return }
        UIApplication.shared.open(url)
    }

    static func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
