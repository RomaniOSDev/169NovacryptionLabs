import SwiftUI

struct IntervalTemplatesView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var workInput: Int
    @Binding var restInput: Int
    @Binding var roundsInput: Int

    @State private var showSaveSheet = false
    @State private var templateName = ""
    @State private var selectedTemplateId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Templates", subtitle: "Quick presets for your interval")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.allTemplates) { template in
                        AppTemplateCard(
                            template: template,
                            isSelected: selectedTemplateId == template.id
                        ) {
                            selectedTemplateId = template.id
                            store.applyTemplate(template)
                            workInput = template.workSeconds
                            restInput = template.restSeconds
                            roundsInput = template.roundsCount
                        }
                        .contextMenu {
                            if !template.isBuiltIn {
                                Button("Delete Template", role: .destructive) {
                                    store.deleteCustomTemplate(template.id)
                                }
                            }
                        }
                    }

                    Button {
                        FeedbackManager.lightTap()
                        templateName = ""
                        showSaveSheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(.title2)
                            Text("Save Current")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 100, height: 120)
                        .background(
                            RoundedRectangle(cornerRadius: AppDesign.smallRadius, style: .continuous)
                                .strokeBorder(Color.appPrimary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
        .alert("Save Template", isPresented: $showSaveSheet) {
            TextField("Template name", text: $templateName)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                let trimmed = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                store.saveCustomTemplate(name: trimmed, work: workInput, rest: restInput, rounds: roundsInput)
                FeedbackManager.success()
            }
        } message: {
            Text("Save current interval settings as a template.")
        }
    }
}
