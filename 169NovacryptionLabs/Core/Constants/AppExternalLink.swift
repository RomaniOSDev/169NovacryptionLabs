import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://novacryptionlabs169.site/privacy/171"
        case .termsOfUse:
            return "https://novacryptionlabs169.site/terms/171"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    var title: String {
        switch self {
        case .privacyPolicy:
            return "Privacy Policy"
        case .termsOfUse:
            return "Terms of Use"
        }
    }

    var systemImage: String {
        switch self {
        case .privacyPolicy:
            return "hand.raised.fill"
        case .termsOfUse:
            return "doc.text.fill"
        }
    }
}
