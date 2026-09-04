//
//  InterviewViewModel.swift
//  Voxy
//

import Foundation
import Observation

@MainActor
@Observable
final class InterviewViewModel {

    let jobPosting: JobPosting

    var questions: [String] = []
    var isLoading = false
    var errorMessage: String?

    var tokenUsagePercent = 0

    private let service: QuestionGenerationServiceProtocol

    private var askedQuestions: [String] = []

    init(
        jobPosting: JobPosting,
        service: QuestionGenerationServiceProtocol? = nil
    ) {
        self.jobPosting = jobPosting
        self.service = service ?? FoundationQuestionGenerationService()
    }

    var availabilityMessage: String? {
        service.availabilityMessage
    }

    func generateQuestions() async {
        let description = jobPosting.jobDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !description.isEmpty else {
            errorMessage = "Esta vaga não tem descrição para gerar perguntas."
            return
        }

        guard !isLoading else {
            return
        }

        isLoading = true
        errorMessage = nil
        questions = []

        defer {
            isLoading = false
            tokenUsagePercent = service.tokenUsagePercent
        }

        do {
            let generated = try await service.generateQuestions(
                for: description,
                avoiding: askedQuestions
            )

            questions = generated
            askedQuestions.append(contentsOf: generated)

        } catch {
            handleGenerationError(error)
        }
    }

    func startNewInterview() {
        askedQuestions = []
        questions = []
        errorMessage = nil

        service.reset()

        tokenUsagePercent = service.tokenUsagePercent
    }

    // MARK: - Error Handling

    private func handleGenerationError(_ error: Error) {
        let nsError = error as NSError

        print("========== FOUNDATION MODELS ERROR ==========")
        print("Domain:", nsError.domain)
        print("Code:", nsError.code)
        print("Description:", nsError.localizedDescription)
        print("UserInfo:", nsError.userInfo)
        print("=============================================")

        let fullError = String(describing: nsError.userInfo)

        if fullError.contains("SensitiveContentAnalysisML")
            || fullError.contains("ModelManagerError")
            || fullError.localizedCaseInsensitiveContains("rate limit") {

            errorMessage = """
            O modelo de IA está temporariamente indisponível.

            Aguarde alguns instantes e tente gerar as perguntas novamente.
            """

            return
        }

        errorMessage = """
        Não foi possível gerar as perguntas.

        Tente novamente em alguns instantes.
        """
    }
}
