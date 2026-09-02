//
//  FeedbackEngine.swift
//  Voxy
//
//  Created by Voxy Team on 01/09/26.
//

import Foundation
import FoundationModels

@Generable
struct AnswerFeedback {
    @Guide(description: "Seja honesto e dê uma nota de 1 a 5 que condiz com a clareza e a articulação da resposta.", .range(1...5))
    let articulationScore: Int

    @Guide(description: "Seja honesto e diga duas a três frases sobre a articulação: o que ficou claro e o que ficou confuso.")
    let articulationNotes: String

    @Guide(description: "Vícios de linguagem e muletas encontrados no texto (ex.: repetições, 'tipo', 'né', 'então'). Deixe vazio se não houver.")
    let languageVices: [String]

    @Guide(description: "Seja honesto com os pontos técnicos fortes demonstrados na resposta. Valide se o que o usuário respondeu condiz com a pergunta feita.")
    let technicalStrengths: [String]

    @Guide(description: "Seja honesto e aponte lacunas técnicas na resposta do usuário ou pontos a melhorar, enquadrados como sugestões de estudo.")
    let technicalGaps: [String]

    @Guide(description: "Seja honesto e faça um resumo final acionável, em uma frase.")
    let summary: String
}

@MainActor
protocol FeedbackEngineProtocol {
    
    var availabilityMessage: String? { get }

    /// Avalia a resposta a uma pergunta e retorna o feedback estruturado.
    /// `question` pode ser vazia (a análise foca só na resposta).
    func evaluate(question: String, answer: String) async throws -> AnswerFeedback
}
// Implementação on-device (offline-first) baseada no FoundationModels

@MainActor
final class FoundationFeedbackEngine: FeedbackEngineProtocol {
    private let model = SystemLanguageModel.default
    private let instructions: String

    /// Temperatura baixa: feedback deve ser estável e consistente
    /// (o oposto da geração de perguntas, que busca variedade).
    private let options = GenerationOptions(temperature: 0.3)

    init() {
        instructions = """
        Você é um avaliador de entrevistas técnicas em tecnologia e design. \
        Avalie a RESPOSTA do candidato de forma construtiva, específica e honesta, \
        em português. Considere três eixos: (1) articulação da resposta e clareza; \
        (2) vícios de linguagem e muletas; (3) conteúdo técnico frente à pergunta feita. \
        Baseie o feedback apenas no texto fornecido levando em consideração a pergunta que foi feita, sem inventar informações, e \
        enquadre lacunas técnicas como sugestões de estudo, não como verdades absolutas.
        """
    }

    var availabilityMessage: String? {
        switch model.availability {
        case .available:
            return nil
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Ative o Apple Intelligence nos Ajustes para gerar o feedback."
        case .unavailable(.deviceNotEligible):
            return "Este dispositivo não é compatível com o Apple Intelligence."
        case .unavailable(.modelNotReady):
            return "O modelo ainda está sendo preparado. Tente novamente em instantes."
        case .unavailable:
            return "O modelo de IA não está disponível neste dispositivo."
        }
    }

    func evaluate(question: String, answer: String) async throws -> AnswerFeedback {
        // Sessão nova por avaliação: análise stateless, contexto (tokens) sempre limpo.
        let session = LanguageModelSession(instructions: instructions)
        let prompt = makePrompt(question: question, answer: answer)

        let response = try await session.respond(
            to: prompt,
            generating: AnswerFeedback.self,
            options: options
        )
        return response.content
    }

    private func makePrompt(question: String, answer: String) -> String {
        // Delimitadores explícitos evitam que instruções contidas na fala do
        // candidato sejam interpretadas como comando ao modelo.
        let questionBlock = question.isEmpty
            ? "PERGUNTA: (não informada)"
            : "PERGUNTA:\n\"\"\"\n\(question)\n\"\"\""

        return """
        \(questionBlock)

        RESPOSTA DO CANDIDATO:
        \"\"\"
        \(answer)
        \"\"\"

        Gere o feedback estruturado da resposta acima.
        """
    }
}
