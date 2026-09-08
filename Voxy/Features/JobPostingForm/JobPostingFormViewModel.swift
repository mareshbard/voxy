//
//  JobPostingFormViewModel.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class JobPostingFormViewModel {

    var title = ""
    var companyName = ""
    var jobDescription = ""
    var isRecognizing = false
    var errorMessage: String?
    var questionCount: Int = 6

    private let store: JobPostingStore
    private let textRecognitionService: TextRecognitionServiceProtocol
    private let editingJobPosting: JobPosting?

    var isEditing: Bool {
        editingJobPosting != nil
    }

    var canTrain: Bool {
        !title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        && !jobDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    init(
        store: JobPostingStore,
        editingJobPosting: JobPosting? = nil,
        textRecognitionService: TextRecognitionServiceProtocol? = nil
    ) {
        self.store = store
        self.editingJobPosting = editingJobPosting
        self.textRecognitionService =
            textRecognitionService ?? VisionTextRecognitionService()

        if let editingJobPosting {
            title = editingJobPosting.title
            companyName = editingJobPosting.companyName
            jobDescription = editingJobPosting.jobDescription
        }
    }

    func importRequirements(from imageData: Data?) async {
        isRecognizing = true
        errorMessage = nil

        defer {
            isRecognizing = false
        }

        guard let imageData else {
            errorMessage = "Nao foi possivel carregar a imagem selecionada."
            return
        }

        do {
            let recognizedText =
                try await textRecognitionService.recognizeText(
                    from: imageData
                )

            if recognizedText.isEmpty {
                errorMessage = "Nao foi possivel encontrar texto na imagem."
            } else {
                jobDescription = recognizedText
            }

        } catch {
            errorMessage = "Nao foi possivel ler a imagem."
        }
    }

    func save() -> JobPosting? {
        let trimmedTitle = title
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedCompanyName = companyName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let trimmedDescription = jobDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if let editingJobPosting {
                editingJobPosting.title = trimmedTitle
                editingJobPosting.companyName = trimmedCompanyName
                editingJobPosting.jobDescription = trimmedDescription

                try store.update()

                return editingJobPosting
            }

            let jobPosting = JobPosting(
                title: trimmedTitle,
                companyName: trimmedCompanyName,
                jobDescription: trimmedDescription
            )

            try store.save(jobPosting)

            return jobPosting

        } catch {
            errorMessage = isEditing
                ? "Nao foi possivel atualizar a vaga."
                : "Nao foi possivel salvar a vaga."

            return nil
        }
    }
}
