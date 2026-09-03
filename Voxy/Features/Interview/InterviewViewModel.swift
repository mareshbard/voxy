import Foundation
import Observation

@MainActor
@Observable
final class InterviewViewModel {
    let jobPosting: JobPosting
    var questions: [String] = []
    var isLoading = false
    var errorMessage: String?

//  Debug da quantidade de tokens utilizado nessa entrevista
    var tokenUsagePercent = 0
    
    private let service: QuestionGenerationServiceProtocol

//  Todas as perguntas geradas nessa entrevista ficarão aqui
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

        isLoading = true
        errorMessage = nil
        questions = []
        defer { isLoading = false }

        do {
            let generated = try await service.generateQuestions(
                for: description,
                avoiding: askedQuestions
            )
            questions = generated
            askedQuestions.append(contentsOf: generated)
        } catch {
            errorMessage = "Erro ao gerar perguntas: \(error.localizedDescription)"
        }

        tokenUsagePercent = service.tokenUsagePercent
    }

//     Reinicia a entrevista e os tokens
    func startNewInterview() {
        askedQuestions = []
        questions = []
        errorMessage = nil
        service.reset()
        tokenUsagePercent = service.tokenUsagePercent
    }
}
