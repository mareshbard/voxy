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

    @State private var shouldStartInterview = false
    @State private var savedJobPosting: JobPosting?
    @State private var selectedPhoto: PhotosPickerItem?

    @Bindable var viewModel: JobPostingFormViewModel

    var onStartTraining: ((JobPosting) -> Void)?

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
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
                        PhotoPickerItem(
                            title: "Adicionar imagem da vaga",
                            isRecognizing: viewModel.isRecognizing,
                            selection: $selectedPhoto
                        )
                        
                        Text("Para uma melhor leitura, insira a imagem recortada, contendo apenas as informações da vaga.")
                                .font(.custom("Nunito-SemiBold", size: 14))
                                .foregroundStyle(Color("SecondaryFontColor"))
                                .fixedSize(horizontal: false, vertical: true)
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

                    Spacer()

                    Button("Treinar!") {
                        startTraining()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(GameButton())
                    .disabled(!canSave)

                    Spacer()
                }
                .padding(24)
            }
            .navigationDestination(
                isPresented: $shouldStartInterview
            ) {
                if let jobPosting = savedJobPosting {
                    InterviewLoadingView(
                        jobPosting: jobPosting
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                Color("BackgroundJobCardColor")
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .accessibilityLabel(
                                Text("Cancelar")
                            )
                            .accessibilityHint(
                                "Cancela o formulário e volta à tela anterior"
                            )
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button {
                        saveAndDismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .accessibilityLabel(
                                Text("Salvar")
                            )
                            .accessibilityHint(
                                "Salva a vaga e volta para a lista"
                            )
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryBlue"))
                    .disabled(!canSave)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: selectedPhoto) { _, newPhoto in
                guard let newPhoto else { return }

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

    private var canSave: Bool {
        !viewModel.title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
            && !viewModel.companyName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
            && !viewModel.jobDescription
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
    }

    private func saveAndDismiss() {
        guard viewModel.save() != nil else {
            return
        }

        // Fecha a sheet; a lista recarrega no onDismiss e mostra a nova vaga.
        dismiss()
    }

    private func startTraining() {
        guard let jobPosting = viewModel.save() else {
            return
        }

        if let onStartTraining {
            onStartTraining(jobPosting)
        } else {
            savedJobPosting = jobPosting
            shouldStartInterview = true
        }
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
