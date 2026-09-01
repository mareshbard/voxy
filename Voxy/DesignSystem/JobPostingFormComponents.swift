import PhotosUI
import SwiftUI

enum VoxyDesignColor {
    static let sheetGroupedBackground = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
                : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        }
    )

    static let cardBackground = Color(.systemBackground)
    static let fieldBackground = Color(.secondarySystemBackground)
    static let placeholderBackground = Color(.tertiarySystemFill)
    static let outline = Color(.separator)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    static let sectionLabel = Color(.secondaryLabel)
    static let actionBlue = Color(red: 0, green: 0.53, blue: 1)
    static let actionRed = Color(red: 1, green: 0.22, blue: 0.24)
    static let primaryButton = Color(red: 0, green: 0.58, blue: 0.96)
}

struct JobPostingSheetHeader: View {
    let title: String
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack {
            Button("Cancelar", action: onCancel)
                .font(Font.custom("SF Pro", size: 15))
                .foregroundColor(VoxyDesignColor.actionRed)

            Spacer()

            Text(title)
                .font(
                    Font.custom("Nunito", size: 17)
                        .weight(.semibold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(VoxyDesignColor.primaryText)

            Spacer()

            Button("Salvar", action: onSave)
                .font(Font.custom("SF Pro", size: 15))
                .foregroundColor(VoxyDesignColor.actionBlue)
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
        .padding(.bottom, 12)
    }
}

struct AssistantMessageCard: View {
    let eyebrow: String
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 90, height: 90)
                .background(VoxyDesignColor.placeholderBackground)

            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow)
                    .font(
                        Font.custom("Nunito", size: 12)
                            .weight(.bold)
                    )
                    .kerning(1.1)
                    .foregroundColor(VoxyDesignColor.secondaryText)

                Text(title)
                    .font(Font.custom("Nunito-Black", size: 19))
                    .foregroundColor(Color("FontColor"))

                Text(message)
                    .font(
                        Font.custom("Nunito", size: 13)
                            .weight(.semibold)
                    )
                    .foregroundColor(VoxyDesignColor.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(VoxyDesignColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

struct VoxyFormTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VoxyFormSectionLabel(title)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(
                        Font.custom("Nunito", size: 15)
                            .weight(.bold)
                    )
                    .foregroundColor(VoxyDesignColor.secondaryText)
            )
            .font(
                Font.custom("Nunito", size: 15)
                    .weight(.bold)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(VoxyDesignColor.fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(VoxyDesignColor.outline, lineWidth: 1.97)
            )
        }
    }
}

struct VoxyImagePickerField: View {
    @Binding var selection: PhotosPickerItem?
    let isRecognizing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VoxyFormSectionLabel("PRINT DA VAGA")

            PhotosPicker(selection: $selection, matching: .images) {
                VStack(alignment: .center, spacing: 8) {
                    if isRecognizing {
                        ProgressView()
                    } else {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 27))
                            .foregroundStyle(VoxyDesignColor.primaryText)
                    }

                    Text(isRecognizing ? "Lendo imagem..." : "Adicionar imagem")
                        .font(
                            Font.custom("Nunito", size: 14)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(VoxyDesignColor.primaryText)

                    Text("Máx.: 50 MB")
                        .font(
                            Font.custom("Nunito", size: 12)
                                .weight(.semibold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(VoxyDesignColor.secondaryText)
                }
                .padding(0)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 111.99213,
                    maxHeight: 111.99213,
                    alignment: .center
                )
            }
            .buttonStyle(.plain)
            .disabled(isRecognizing)
            .frame(
                maxWidth: .infinity,
                minHeight: 111.99213,
                maxHeight: 111.99213,
                alignment: .center
            )
            .background(VoxyDesignColor.fieldBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.99)
                    .stroke(
                        VoxyDesignColor.outline,
                        style: StrokeStyle(
                            lineWidth: 1.97234,
                            dash: [3.94468, 1.97234]
                        )
                    )
            )
        }
    }
}

struct VoxyTextEditorField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VoxyFormSectionLabel(title)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(
                        Font.custom("Nunito", size: 14)
                            .weight(.semibold)
                    )
                    .scrollContentBackground(.hidden)
                    .padding(12)

                if text.isEmpty {
                    Text(placeholder)
                        .font(
                            Font.custom("Nunito", size: 14)
                                .weight(.semibold)
                        )
                        .foregroundColor(VoxyDesignColor.secondaryText)
                        .padding(10)
                        .allowsHitTesting(false)
                }
            }
            .padding(10)
            .frame(
                maxWidth: .infinity,
                minHeight: 100,
                maxHeight: 100,
                alignment: .topLeading
            )
            .background(VoxyDesignColor.fieldBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .inset(by: 0.99)
                    .stroke(VoxyDesignColor.outline, lineWidth: 1.97234)
            )
        }
    }
}

struct VoxyPrimaryButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(
                    Font.custom("Nunito", size: 17)
                        .weight(.bold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(VoxyDesignColor.primaryButton)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .opacity(isEnabled ? 1 : 0.4)
        }
    }
}

private struct VoxyFormSectionLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(
                Font.custom("Nunito", size: 12)
                    .weight(.bold)
            )
            .kerning(0.72)
            .foregroundColor(VoxyDesignColor.sectionLabel)
    }
}
