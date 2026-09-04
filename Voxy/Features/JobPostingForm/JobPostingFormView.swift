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
    
    @State private var shouldStartInterview: Bool = false
    @State private var savedJobPosting: JobPosting? = nil
    @Bindable var viewModel: JobPostingFormViewModel
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    HeaderSectionForm()
                        .frame(maxWidth: .infinity)
                    
                        Section {
                            FocusableTextField(placeholder: "Ex: Front-end Developer Sr., UX Designer Jr...", text: $viewModel.title)
                        } header: {
                            SectionLabel(title: "NOME DA VAGA", required: true)
                        }
                        
                        Section {
                            FocusableTextField(placeholder: "Digite o nome da empresa...", text: $viewModel.companyName)
                        } header: {
                            SectionLabel(title: "EMPRESA", required: true)
                        }
                        
                        Section {
                            PhotoPickerItem(
                                title: "Adicionar imagem da vaga",
                                isRecognizing: viewModel.isRecognizing,
                                selection: $selectedPhoto
                            )
                        } header: {
                            SectionLabel(title: "PRINT DA VAGA", required: false)
                        }
                        
                        Section {
                            FocusableTextFieldDescription(placeholder: "Digite os requisitos da vaga ou carregue uma imagem...", text: $viewModel.jobDescription)
                        } header: {
                            SectionLabel(title: "DESCRIÇÃO DA VAGA", required: true)
                        }
                        
//                        Section {
//                            QuestionCountSelector(selectedValue: $viewModel.questionCount)
//                            
//                        } header: {
//                            SectionLabel(title: "NÚMERO DE PERGUNTAS", required: false)
//                        }
                        Spacer()
                    
                        Button("Treinar agora!") {
                            if let jobPosting = viewModel.save() {
                                savedJobPosting = jobPosting
                                shouldStartInterview = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(GameButton())
                        .disabled(viewModel.title.isEmpty || viewModel.companyName.isEmpty || viewModel.jobDescription.isEmpty)
                        Spacer()
                    }
                    .padding(24)
                    .navigationDestination(isPresented: $shouldStartInterview) {
                        if let savedJobPosting {
                            InterviewView(jobPosting: savedJobPosting, feedbackEngine: FoundationFeedbackEngine())
                        }
                    }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundJobCardColor").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .accessibilityLabel(Text("Cancelar"))
                            .accessibilityHint("Cancela o formulário e volta à tela anterior")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let jobPosting = viewModel.save() {
                            savedJobPosting = jobPosting
                            shouldStartInterview = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .accessibilityLabel(Text("Salvar"))
                            .accessibilityHint("Envia o formulário para a vaga ser salva")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("PrimaryBlue"))
                    .disabled(viewModel.title.isEmpty || viewModel.companyName.isEmpty || viewModel.jobDescription.isEmpty)
                    
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: selectedPhoto) { _, newPhoto in
                guard let newPhoto else { return }
                Task {
                    let imageData = try? await newPhoto.loadTransferable(type: Data.self)
                    await viewModel.importRequirements(from: imageData)
                }
            }
        }
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
    
    JobPostingFormView(
        viewModel: viewModel
    )
}


