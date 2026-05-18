import SwiftUI

struct NumericStepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var errorText: String?
    var shakeTrigger: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                HStack(spacing: 0) {
                    stepButton(systemName: "minus") {
                        if value > range.lowerBound {
                            value -= 1
                            FeedbackManager.lightTap()
                        }
                    }
                    TextField("", value: $value, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 56)
                        .foregroundStyle(Color.appTextPrimary)
                    stepButton(systemName: "plus") {
                        if value < range.upperBound {
                            value += 1
                            FeedbackManager.lightTap()
                        }
                    }
                }
                .background(Color.appBackground.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            if let errorText {
                Text(errorText)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .shake(trigger: shakeTrigger)
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
    }
}
