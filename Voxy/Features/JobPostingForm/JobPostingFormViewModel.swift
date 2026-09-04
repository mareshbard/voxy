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

    var canTrain: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !jobDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let store: JobPostingStore
    private let textRecognitionService: TextRecognitionServiceProtocol

    init(
        store: JobPostingStore,
        textRecognitionService: TextRecognitionServiceProtocol? = nil
    ) {
        self.store = store
        self.textRecognitionService = textRecognitionService ?? VisionTextRecognitionService()
    }

    func importRequirements(from imageData: Data?) async {
        isRecognizing = true
        errorMessage = nil
        defer { isRecognizing = false }

        guard let imageData else {
            errorMessage = "Nao foi possivel carregar a imagem selecionada."
            return
        }

        do {
            let recognizedText = try await textRecognitionService.recognizeText(
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

        let jobPosting = JobPosting(
            title: trimmedTitle,
            companyName: trimmedCompanyName,
            jobDescription: trimmedDescription
        )

        do {
            try store.save(jobPosting)
            return jobPosting
        } catch {
            errorMessage = "Nao foi possivel salvar a vaga."
            return nil
        }
    }
}
