//
//  FeedbackEngine.swift
//  Voxy
//
//  Created by Voxy Team on 01/09/26.
//

import Foundation
import FoundationModels

@Generable
struct AnswerFeedback: Hashable {
    @Guide(description: "Nota de 1 a 5 para a clareza e articulação. ATENÇÃO: Respostas evasivas, vazias ou 'não sei' devem obrigatoriamente receber nota 1 ou 2.", .range(1...5))
    let articulationScore: Int

    @Guide(description: "Análise sucinta da articulação em 2-3 frases. Se a resposta for 'não sei' ou muito curta, aponte a falta de desenvolvimento. Dizer que não sabe NÃO conta como clareza.")
    let articulationNotes: String

    @Guide(description: "Vícios de linguagem e muletas de fala (ex.: repetições, 'tipo', 'né'). Deixe a lista totalmente vazia [] se não houver.")
    let languageVices: [String]

    @Guide(description: "Pontos técnicos fortes REALMENTE demonstrados. REGRA OBRIGATÓRIA: Se a resposta for 'não sei', vazia ou incorreta, retorne uma lista VAZIA []. NUNCA invente elogios.", .maximumCount(3))
    let technicalStrengths: [String]

    @Guide(description: "Lacunas técnicas enquadradas como sugestões de estudo. Se o candidato não soube responder, descreva o tópico da pergunta como algo a ser estudado.", .count(2...4))
    let technicalGaps: [String]

    @Guide(description: "Resumo acionável do desempenho nesta resposta em uma frase curta.")
    let summary: String
}

@Generable
struct FinalFeedback {
    @Guide(description: "Ações concretas do que praticar ou estudar. Cada item DEVE começar com um verbo no imperativo (ex.: 'Estude...', 'Pratique...'). Foco exclusivo em melhorias futuras.", .count(2...4))
    let improve: [String]

    @Guide(description: "Elogios a acertos concretos demonstrados. REGRA OBRIGATÓRIA: Se o candidato disse que não sabia ou deu respostas vazias em toda a entrevista, retorne uma lista VAZIA []. NUNCA invente acertos.", .maximumCount(3))
    let bestMoments: [String]

    @Guide(description: "Análise da CLAREZA e organização em argumentos bem estruturados. Se o candidato apenas disse 'não sei' ou não desenvolveu respostas, retorne uma lista VAZIA [].", .maximumCount(2))
    let clarity: [String]

    @Guide(description: "Vícios e muletas usados (ex.: 'tipo', 'né'). Cada item é uma única palavra ou expressão curta. Se não houver vícios, retorne uma lista VAZIA [].", .maximumCount(3))
    let vicios: [String]

    @Guide(description: "Análise da PROFUNDIDADE técnica. Se as respostas do candidato foram sucintas, evasivas ou 'não sei', retorne uma lista VAZIA [].", .maximumCount(3))
    let profundity: [String]
}

@MainActor
protocol FeedbackEngineProtocol {
    var availabilityMessage: String? { get }
    func evaluate(question: String, answer: String) async throws -> AnswerFeedback
}

@MainActor
protocol FinalFeedbackProtocol {
    var availabilityMessage: String? { get }
    func evaluate(feedbacks: String) async throws -> FinalFeedback
}

// Implementação on-device (offline-first) baseada no FoundationModels
@MainActor
final class FoundationFeedbackEngine: FeedbackEngineProtocol, FinalFeedbackProtocol {
    
    private let model = SystemLanguageModel.default
    private let instructions: String

    /// Temperatura baixa (0.1) força o modelo a respeitar
    /// rigidamente as restrições de formatação e listas vazias.
    private let options = GenerationOptions(temperature: 0.1)

    init() {
        instructions = """
        Você é um avaliador estrito de entrevistas técnicas em tecnologia e design. \
        Sua prioridade máxima é ser REALISTA, HONESTO e EVITAR ELOGIOS FALSOS.
        
        Siga rigorosamente estas regras:
        1. BASEIE-SE APENAS NO TEXTO: Não deduza conhecimento que não esteja escrito explicitamente na resposta.
        2. REGRA DO 'NÃO SEI': Se o candidato responder "não sei", der uma resposta vazia ou evasiva, você DEVE retornar as listas de pontos fortes, melhores momentos, clareza e profundidade como listas VAZIAS [].
        3. ENQUADRAMENTO: Trate desconhecimento técnico como sugestão de estudo, sem tentar compensating com elogios artificiais à honestidade do candidato.
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
        let session = LanguageModelSession(instructions: instructions)
        let prompt = makePrompt(question: question, answer: answer)

        let response = try await session.respond(
            to: prompt,
            generating: AnswerFeedback.self,
            options: options
        )
        return response.content
    }

    func evaluate(feedbacks: String) async throws -> FinalFeedback {
        let session = LanguageModelSession(instructions: instructions)
        let prompt = makePrompt(feedbacks: feedbacks)

        let response = try await session.respond(
            to: prompt,
            generating: FinalFeedback.self,
            options: options
        )
        return deduplicatedAcrossSections(response.content)
    }

    private func makePrompt(question: String, answer: String) -> String {
        let questionBlock = question.isEmpty
            ? "PERGUNTA: (não informada)"
            : "PERGUNTA:\n\"\"\"\n\(question)\n\"\"\""

        return """
        \(questionBlock)

        RESPOSTA DO CANDIDATO:
        \"\"\"
        \(answer)
        \"\"\"

        Analise a RESPOSTA estritamente com base na PERGUNTA. 
        REGRA CRÍTICA: Se a resposta for "não sei", muito curta ou evasiva, ZERE a lista de pontos fortes, retornando-a totalmente VAZIA. Concentre o feedback apenas no que deve ser estudado.
        """
    }

    private func makePrompt(feedbacks: String) -> String {
        let block = feedbacks.isEmpty
            ? "FEEDBACKS: (não encontrados)"
            : "FEEDBACKS DAS RESPOSTAS:\n\"\"\"\n\(feedbacks)\n\"\"\""

        return """
        \(block)

        Consolide os feedbacks da entrevista em um relatório final rigoroso. 
        Cada seção trata de um aspecto INDEPENDENTE. Não repita a mesma frase em seções diferentes.
        
        REGRA CRÍTICA: Se os feedbacks mostram que o candidato respondeu apenas "não sei" ou deu respostas vazias, DEIXE as listas "bestMoments", "clarity" e "profundity" COMPLETAMENTE VAZIAS []. Foque o retorno unicamente em "improve".
        """
    }

    private func deduplicatedAcrossSections(_ feedback: FinalFeedback) -> FinalFeedback {
        var seen = Set<String>()

        func unique(_ items: [String]) -> [String] {
            items.filter { item in
                let key = normalizedKey(item)
                guard !key.isEmpty, !seen.contains(key) else { return false }
                seen.insert(key)
                return true
            }
        }

        return FinalFeedback(
            improve: unique(feedback.improve),
            bestMoments: unique(feedback.bestMoments),
            clarity: unique(feedback.clarity),
            vicios: unique(feedback.vicios),
            profundity: unique(feedback.profundity)
        )
    }

    private func normalizedKey(_ text: String) -> String {
        text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
