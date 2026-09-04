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
    @Bindable var viewModel: JobPostingFormViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var shouldNavigate: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack { // <--- Adicionado para permitir push navigation dentro do Sheet
            VStack(spacing: 0) {
                JobPostingSheetHeader(
                    title: "Nova vaga",
                    onCancel: { dismiss() },
                    onSave: {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        AssistantMessageCard(
                            eyebrow: "Mia diz:",
                            title: "Vamos treinar!",
                            message: "Insira a descrição da vaga em texto ou adicionar um print se preferir!"
                        )
                        
                        VoxyFormTextField(
                            title: "NOME DA VAGA*",
                            placeholder: "Ex: UX Designer Jr., Front-end Dev...",
                            text: $viewModel.title
                        )
                        
                        VoxyImagePickerField(
                            selection: $selectedPhoto,
                            isRecognizing: viewModel.isRecognizing
                        )
                        
                        VoxyTextEditorField(
                            title: "DESCRIÇÃO EM TEXTO",
                            placeholder: "Ou cole aqui o texto da vaga...",
                            text: $viewModel.jobDescription
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
                
                VoxyPrimaryButton(title: "Treinar agora!") {
                    // Opcional: Salva a vaga antes de ir para o treino
                    _ = viewModel.save()
                    shouldNavigate = true
                }
                .disabled(!viewModel.canTrain)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationDestination(isPresented: $shouldNavigate) {
         //       FeedbackView()
            }
            .background(VoxyDesignColor.sheetGroupedBackground)
            .alert(
                "Erro ao ler imagem",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                guard let newPhoto else { return }
                
                Task {
                    let imageData = try? await newPhoto.loadTransferable(type: Data.self)
                    await viewModel.importRequirements(from: imageData)
                }
            }
        }
        .presentationBackground(VoxyDesignColor.sheetGroupedBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
#Preview {
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
    
    return JobPostingFormPreview(
        viewModel: viewModel
    )
}

private struct JobPostingFormPreview: View {
    let viewModel: JobPostingFormViewModel
    
    @State private var isPresented = true
    
    var body: some View {
        Color.gray.opacity(0.15)
            .ignoresSafeArea()
            .sheet(isPresented: $isPresented) {
                JobPostingFormView(
                    viewModel: viewModel
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
    }
}
