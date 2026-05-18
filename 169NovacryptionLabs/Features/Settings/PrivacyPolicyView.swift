import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdown = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    Text(.init(markdown))
                        .foregroundStyle(Color.appTextPrimary)
                        .tint(Color.appPrimary)
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .appScreenStyle()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.appBackgroundFallback, for: .navigationBar)
        }
        .onAppear { loadPolicy() }
    }

    private func loadPolicy() {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            markdown = text
        } else {
            markdown = "# Privacy Policy\nContent unavailable."
        }
    }
}
