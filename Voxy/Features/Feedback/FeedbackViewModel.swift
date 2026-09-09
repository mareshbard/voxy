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
    var answers: [String] = [] // respostas transcritas cruas, alinhadas com `feedbacks`
    var job: JobPosting // recebe a vaga ligada ao feedback
    
    init(job: JobPosting, engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil) {
        self.job = job
        self.engine = engine ?? FoundationFeedbackEngine()
    }

    var availabilityMessage: String? {
        engine.availabilityMessage
    }

    /// Indica se houve ao menos uma resposta transcrita para avaliar.
    /// Quando o usuário pula todas as perguntas, `feedbacks` fica vazio.
    var hasAnswers: Bool {
        !feedbacks.isEmpty
    }

    /// Sinal de qualidade da entrevista: quando o feedback final não trouxe
    /// nenhum ponto positivo real (melhores momentos, clareza e profundidade
    /// todos vazios), o desempenho foi fraco — ex.: respostas "não sei". Só é
    /// confiável depois que o feedback final é gerado.
    var hadWeakPerformance: Bool {
        guard let final = finalFeedback else { return false }
        return final.bestMoments.isEmpty
            && final.clarity.isEmpty
            && final.profundity.isEmpty
    }

    /// Título do cabeçalho, coerente com o desempenho real da entrevista.
    var headerTitle: String {
        guard hasAnswers else { return "Entrevista incompleta" }
        if isLoading || finalFeedback == nil { return "Quase lá!" }
        return hadWeakPerformance ? "Bora treinar mais!" : "Mandou bem!"
    }

    /// Subtítulo do cabeçalho, coerente com o desempenho real da entrevista.
    var headerSubtitle: String {
        guard hasAnswers else { return "Você não respondeu nenhuma pergunta." }
        if isLoading || finalFeedback == nil { return "Estamos analisando suas respostas..." }
        return hadWeakPerformance
            ? "Tem bastante espaço para evoluir. Confira as dicas de melhoria abaixo."
            : "Você está arrasando!"
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
        // Sem nenhuma resposta transcrita não há o que avaliar. Gerar mesmo
        // assim faria o modelo inventar feedback por causa do schema @Generable.
        guard hasAnswers else {
            finalFeedback = nil
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // Serializa os feedbacks já coletados em texto para o modelo resumir
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

    /// Verdadeiro se ao menos uma resposta transcrita teve conteúdo real —
    /// sinal determinístico (lido do texto bruto, não do modelo), imune às
    /// alucinações da avaliação.
    var hasSubstantiveAnswer: Bool {
        answers.contains { isSubstantive($0) }
    }

    /// Uma resposta é substantiva quando não é vazia, não é uma frase de
    /// desistência ("não sei", "sei lá"...) e tem pelo menos algumas palavras.
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

        // Uma resposta real de entrevista tem ao menos uma frase; respostas com
        // pouquíssimas palavras não têm conteúdo avaliável.
        let wordCount = normalized.split { $0 == " " || $0 == "\n" }.count
        return wordCount >= 4
    }

    /// Corrige alucinações do modelo de consolidação com um sinal determinístico.
    /// Quando NENHUMA resposta teve conteúdo real (ex.: "não sei" em tudo), não
    /// existem pontos positivos, clareza nem profundidade a comentar — zeramos
    /// essas seções, ignorando o que o modelo final possa ter inventado.
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
    // MARK: Funções para a tela de feedback
    
    var bestMoments: [String] {
        feedback?.technicalStrengths ?? []
    }
    
    var improvementSuggestions: [String] {
        feedback?.technicalGaps ?? []
    }
    
    func saveLastFeedback() {
        // Não persiste um registro vazio quando não houve respostas.
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
