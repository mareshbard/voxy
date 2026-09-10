import Foundation
import Observation

@MainActor
@Observable
final class FeedbackViewModel {
    var question = ""
    var answer = ""
    var feedback: AnswerFeedback?
    var isLoading = false
    var errorMessage: String?
    var responses: [String] = []
    private let engine: FeedbackEngineProtocol & FinalFeedbackProtocol
    var finalFeedback: FinalFeedback?
    var feedbacks: [AnswerFeedback] = []
    var answers: [String] = [] // Respostas transcritas cruas
    var job: JobPosting

    init(job: JobPosting, engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil) {
        self.job = job
        self.engine = engine ?? FoundationFeedbackEngine()
    }

    var availabilityMessage: String? {
        engine.availabilityMessage
    }

    var hasAnswers: Bool {
        !feedbacks.isEmpty || !answers.isEmpty
    }

    private var performanceLevel: PerformanceLevel {
        guard let final = finalFeedback else { return .unknown }
        
        let hasBestMoments = !final.bestMoments.isEmpty
        let hasClarityOrProfundity = !final.clarity.isEmpty || !final.profundity.isEmpty
        
        if hasBestMoments {
            return .excellent
        } else if hasClarityOrProfundity {
            return .moderate
        } else {
            return .weak
        }
    }

    /// Retorna o nome da imagem do mascote no Asset Catalog de acordo com o nível de desempenho
    var headerMascotImageName: String {
        guard hasAnswers else { return "mascot_sad" }
        if isLoading || finalFeedback == nil { return "mascot_thinking" }

        switch performanceLevel {
        case .excellent:
            return "MiaFeedbackHappy"       // Raposa sorrindo ("Mandou bem!")
        case .moderate:
            return "MiaFeedbackNeutral"     // Raposa neutra ("Bom ponto de partida!")
        case .weak, .unknown:
            return "MiaFeedbackSad"         // Raposa triste ("Continue a treinar!")
        }
    }
    var miaDescription: String {
        switch performanceLevel {
        case .excellent:
            return "Mia está muito orgulhosa!"
        case .moderate:
            return "Mia está feliz!"
        case .weak, .unknown:
            return "Mia está chateada."
        }
    }
    
    var headerTitle: String {
        guard hasAnswers else { return "Entrevista incompleta" }
        if isLoading || finalFeedback == nil { return "Analisando..." }

        switch performanceLevel {
        case .excellent:
            return "Mandou bem!"
        case .moderate:
            return "Bom ponto de partida!"
        case .weak, .unknown:
            return "Continue a treinar!"
        }
    }

    var headerSubtitle: String {
        guard hasAnswers else { return "Você não respondeu nenhuma pergunta." }
        if isLoading || finalFeedback == nil { return "Estamos analisando as suas respostas..." }

        switch performanceLevel {
        case .excellent:
            return "Você se destacou nas respostas!"
        case .moderate:
            return "Você tentou!"
        case .weak, .unknown:
            return "Tem bastante espaço para evoluir!"
        }
    }

    var canAnalyze: Bool {
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    func analyze() async {
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedAnswer.isEmpty else {
            errorMessage = "Escreva uma resposta para analisar."
            return
        }

        isLoading = true
        errorMessage = nil
        feedback = nil
        defer { isLoading = false }

        do {
            feedback = try await engine.evaluate(
                question: question.trimmingCharacters(in: .whitespacesAndNewlines),
                answer: trimmedAnswer
            )
        } catch {
            errorMessage = "Erro ao gerar feedback: \(error.localizedDescription)"
        }
    }

    func analyzeFinal() async {
        guard hasAnswers else {
            finalFeedback = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let joined = feedbacks.enumerated().map { i, fb in
            """
            Resposta \(i + 1) — nota \(fb.articulationScore)/5
            Articulação: \(fb.articulationNotes)
            Vícios: \(fb.languageVices.joined(separator: ", "))
            Pontos fortes: \(fb.technicalStrengths.joined(separator: "; "))
            Lacunas: \(fb.technicalGaps.joined(separator: "; "))
            """
        }.joined(separator: "\n\n")

        do {
            finalFeedback = sanitized(try await engine.evaluate(feedbacks: joined))
        } catch {
            errorMessage = "Erro ao gerar feedback final: \(error.localizedDescription)"
        }
    }

    var hasSubstantiveAnswer: Bool {
        answers.contains { isSubstantive($0) }
    }

    private func isSubstantive(_ answer: String) -> Bool {
        let normalized = answer
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else { return false }

        let lowEffortPhrases: Set<String> = [
            "nao sei", "nao sei responder", "nao sei dizer", "nao faco ideia",
            "sei la", "nao lembro", "nao me lembro", "passo", "sem resposta",
            "nao entendi", "nao conheco", "nao"
        ]
        if lowEffortPhrases.contains(normalized) { return false }

        let wordCount = normalized.split { $0 == " " || $0 == "\n" }.count
        return wordCount >= 4
    }

    private func sanitized(_ feedback: FinalFeedback) -> FinalFeedback {
        let noSubstance = !answers.isEmpty && !hasSubstantiveAnswer
        guard noSubstance else { return feedback }

        return FinalFeedback(
            improve: feedback.improve,
            bestMoments: [],
            clarity: [],
            vicios: feedback.vicios,
            profundity: []
        )
    }

    var bestMoments: [String] {
        feedback?.technicalStrengths ?? []
    }

    var improvementSuggestions: [String] {
        feedback?.technicalGaps ?? []
    }

    func saveLastFeedback() {
        guard hasAnswers else { return }

        let feedback = InterviewFeedbackRecord(
            improve: finalFeedback?.improve ?? [],
            bestMoments: finalFeedback?.bestMoments ?? [],
            clarity: finalFeedback?.clarity ?? [],
            vicios: finalFeedback?.vicios ?? [],
            profundity: finalFeedback?.profundity ?? []
        )
        job.feedback = feedback
    }
}

// MARK: - Enum Auxiliar de Desempenho
private extension FeedbackViewModel {
    enum PerformanceLevel {
        case excellent
        case moderate
        case weak
        case unknown
    }
}
