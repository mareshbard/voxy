//
//  JobPostingFormViewModelOCRTests.swift
//  Voxy
//
//  Created by Voxy Team on 07/10/26.
//

import Testing
import Foundation
import SwiftData
@testable import Voxy

@MainActor
struct JobPostingFormViewModelOCRTests {

    // CT-31
    @Test
    func successfulRecognitionUpdatesJobDescription() async throws {
        let (_, store) = try makeStore()

        let service = MockTextRecognitionService()
        service.result = "Desenvolvedor iOS com experiência em Swift."

        let viewModel = JobPostingFormViewModel(
            store: store,
            textRecognitionService: service
        )

        await viewModel.importRequirements(from: Data())

        #expect(
            viewModel.jobDescription
                == "Desenvolvedor iOS com experiência em Swift."
        )
    }

    // CT-32
    @Test
    func imageWithoutDataSetsErrorMessage() async throws {
        let (_, store) = try makeStore()

        let service = MockTextRecognitionService()

        let viewModel = JobPostingFormViewModel(
            store: store,
            textRecognitionService: service
        )

        await viewModel.importRequirements(from: nil)

        #expect(
            viewModel.errorMessage
                == "Nao foi possivel carregar a imagem selecionada."
        )
    }

    // CT-33
    @Test
    func emptyRecognitionResultSetsErrorMessage() async throws {
        let (_, store) = try makeStore()

        let service = MockTextRecognitionService()
        service.result = ""

        let viewModel = JobPostingFormViewModel(
            store: store,
            textRecognitionService: service
        )

        await viewModel.importRequirements(from: Data())

        #expect(
            viewModel.errorMessage
                == "Nao foi possivel encontrar texto na imagem."
        )
    }

    // CT-34
    @Test
    func recognitionFailureSetsErrorMessage() async throws {
        let (_, store) = try makeStore()

        let service = MockTextRecognitionService()
        service.shouldThrowError = true

        let viewModel = JobPostingFormViewModel(
            store: store,
            textRecognitionService: service
        )

        await viewModel.importRequirements(from: Data())

        #expect(
            viewModel.errorMessage
                == "Nao foi possivel ler a imagem."
        )
    }

    private func makeStore() throws -> (ModelContainer, JobPostingStore) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        let container = try ModelContainer(
            for: JobPosting.self,
            configurations: configuration
        )

        let store = JobPostingStore(
            modelContext: container.mainContext
        )

        return (container, store)
    }
}

private final class MockTextRecognitionService: TextRecognitionServiceProtocol {

    var result = ""
    var shouldThrowError = false

    func recognizeText(from imageData: Data) async throws -> String {
        if shouldThrowError {
            throw MockTextRecognitionError.recognitionFailed
        }

        return result
    }
}

private enum MockTextRecognitionError: Error {
    case recognitionFailed
}
