import PhotosUI
import SwiftUI

struct JobPostingFormView: View {
    @State private var viewModel = JobPostingViewModel()
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        Form {
            TextField("Titulo da vaga", text: $viewModel.title)

            TextEditor(text: $viewModel.jobDescription)
                .frame(minHeight: 150)

            PhotoPickerItem(title: "Importar requisitos de uma imagem",
                            selection: $selectedPhoto)
        }
        .overlay {
            if viewModel.isRecognizing {
                ProgressView("Lendo imagem...")
            }
        }
        .alert("Erro ao ler imagem",
               isPresented: Binding(
                   get: { viewModel.errorMessage != nil },
                   set: { if !$0 { viewModel.errorMessage = nil } }
               )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            guard let newPhoto else { return }

            Task {
                await importRequirements(from: newPhoto)
            }
        }
    }

    private func importRequirements(from photo: PhotosPickerItem) async {
        do {
            guard let imageData = try await photo.loadTransferable(type: Data.self) else {
                viewModel.errorMessage = "Nao foi possivel carregar a imagem selecionada."
                return
            }

            await viewModel.importRequirements(from: imageData)
        } catch {
            viewModel.errorMessage = "Nao foi possivel carregar a imagem selecionada."
        }
    }
}

#Preview {
    JobPostingFormView()
}
