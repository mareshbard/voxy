//
//  JobPostingFormView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct JobPostingFormView: View {

    @State private var shouldShowJobDetails = false
    @State private var shouldStartInterview = false
    @State private var savedJobPosting: JobPosting?
    @State private var selectedPhoto: PhotosPickerItem?

    @Bindable var viewModel: JobPostingFormViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                customHeader
                
                Image("FoxyMascotFelizBracosPTras")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 102, height: 150)
                    .offset(y: 35)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        HeaderSectionForm()
                            .frame(maxWidth: .infinity)

                        Section {
                            FocusableTextField(
                                placeholder: "Ex: Front-end Developer Sr., UX Designer Jr...",
                                text: $viewModel.title
                            )
                        } header: {
                            SectionLabel(
                                title: "NOME DA VAGA",
                                required: true
                            )
                        }

                        Section {
                            FocusableTextField(
                                placeholder: "Digite o nome da empresa...",
                                text: $viewModel.companyName
                            )
                        } header: {
                            SectionLabel(
                                title: "EMPRESA",
                                required: true
                            )
                        }

                        Section {
                            VStack(alignment: .leading, spacing: 8) {

                                PhotoPickerItem(
                                    title: "Adicionar imagem da vaga",
                                    isRecognizing: viewModel.isRecognizing,
                                    selection: $selectedPhoto
                                )

                                Text(
                                    "Para uma melhor leitura, insira a imagem recortada, contendo apenas as informações da vaga."
                                )
                                .font(
                                    .custom(
                                        "Nunito-SemiBold",
                                        size: 14
                                    )
                                )
                                .foregroundStyle(
                                    Color("SecondaryFontColor")
                                )
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                            }
                        } header: {
                            SectionLabel(
                                title: "PRINT DA VAGA",
                                required: false
                            )
                        }

                        Section {
                            FocusableTextFieldDescription(
                                placeholder: "Digite os requisitos da vaga ou carregue uma imagem...",
                                text: $viewModel.jobDescription
                            )
                        } header: {
                            SectionLabel(
                                title: "DESCRIÇÃO DA VAGA",
                                required: true
                            )
                        }

                        Spacer(minLength: 32)

                        Button {
                            saveAndStartInterview()
                        } label: {
                            Text("Treinar agora!")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(GameButton())
                        .disabled(!canSave)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .background(
                Color("BackgroundJobCardColor")
                    .ignoresSafeArea()
            )
            .navigationDestination(
                isPresented: $shouldShowJobDetails
            ) {
                if let jobPosting = savedJobPosting {
                    JobPostingDetailsView(
                        jobPosting: jobPosting
                    )
                }
            }
            .navigationDestination(
                isPresented: $shouldStartInterview
            ) {
                if let jobPosting = savedJobPosting {
                    InterviewView(
                        jobPosting: jobPosting,
                        feedbackEngine: FoundationFeedbackEngine()
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: selectedPhoto) { _, newPhoto in
                guard let newPhoto else {
                    return
                }

                Task {
                    let imageData = try? await newPhoto
                        .loadTransferable(type: Data.self)

                    await viewModel.importRequirements(
                        from: imageData
                    )
                }
            }
        }
    }

    private var customHeader: some View {
        HStack(alignment: .center) {

            HStack {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(
                                width: 48,
                                height: 48
                            )

                        Image(systemName: "xmark")
                            .font(
                                .system(
                                    size: 22,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                Color("IconPrimaryColor")
                            )
                    }
                    .frame(
                        width: 48,
                        height: 48
                    )
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Cancelar")
                .accessibilityHint(
                    "Cancela e volta para a tela anterior"
                )

                Spacer()
            }
            .frame(width: 91)

            Spacer()

            Text(
                viewModel.isEditing
                    ? "Editar vaga"
                    : "Nova vaga"
            )
            .font(
                .custom(
                    "Satoshi-Bold",
                    size: 17
                )
            )
            .multilineTextAlignment(.center)
            .foregroundStyle(
                Color("IconPrimaryColor")
            )
            .lineLimit(1)

            Spacer()

            Button {
                saveFromHeader()
            } label: {
                Text("Salvar")
                    .font(
                        .system(
                            size: 17,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        width: 91,
                        height: 48
                    )
                    .background {
                        Capsule()
                            .fill(
                                Color("PrimaryBlue")
                            )
                    }
            }
            .buttonStyle(.plain)
            .disabled(!canSave)
            .opacity(
                canSave ? 1 : 0.5
            )
            .accessibilityLabel("Salvar")
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(
            maxWidth: .infinity,
            alignment: .center
        )
    }

    private var canSave: Bool {
        !viewModel.title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        && !viewModel.companyName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        && !viewModel.jobDescription
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }

    private func saveFromHeader() {
        guard let jobPosting = viewModel.save() else {
            return
        }

        if viewModel.isEditing {
            dismiss()
        } else {
            savedJobPosting = jobPosting
            shouldShowJobDetails = true
        }
    }

    private func saveAndStartInterview() {
        guard let jobPosting = viewModel.save() else {
            return
        }

        savedJobPosting = jobPosting
        shouldStartInterview = true
    }
}

#Preview("Nova vaga") {
    let container = try! ModelContainer(
        for: JobPosting.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let store = JobPostingStore(
        modelContext: container.mainContext
    )

    let viewModel = JobPostingFormViewModel(
        store: store
    )

    JobPostingFormView(
        viewModel: viewModel
    )
    .modelContainer(container)
}

#Preview("Editar vaga") {
    let container = try! ModelContainer(
        for: JobPosting.self,
        configurations: ModelConfiguration(
            isStoredInMemoryOnly: true
        )
    )

    let store = JobPostingStore(
        modelContext: container.mainContext
    )

    let jobPosting = JobPosting(
        title: "UX Designer PL",
        companyName: "iFood",
        jobDescription: """
        Ensino Superior completo ou cursando em Design.

        Experiência com UX/UI e prototipação.

        Conhecimento em ferramentas de design.
        """,
        countInterview: 1
    )

    let viewModel = JobPostingFormViewModel(
        store: store,
        editingJobPosting: jobPosting
    )

    JobPostingFormView(
        viewModel: viewModel
    )
    .modelContainer(container)
}
