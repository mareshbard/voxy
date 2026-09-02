//
//  QuestionGenerationService.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedInterview {
    @Guide(
        description: """
        Gere 3 perguntas técnicas de entrevista, ancoradas exclusivamente em \
        tecnologias, ferramentas ou requisitos específicos mencionados na \
        descrição da vaga — nunca pergunte sobre algo que não foi citado nela. \
        Misture pelo menos dois estilos, sem repetir o mesmo formato em todas:
        - Conceitual direta (exemplo para vagas de desenvolvedor: "Como você garante consistência de dados \
        numa arquitetura MVVM?"/ exemplo para designers: "Qual critério você utiliza para decidir se deve aplicar uma abordagem de pesquisa qualitativa ou quantitativa na fase de descoberta (discovery)? )
        - Aplicação prática/cenário (exemplo para vagas de desenvolvedor: "Como você abordaria um cenário onde \
        a API retorna dados inconsistentes?/ exemplo para designers: "Aplicação prática/cenário: Os testes de usabilidade revelaram que a funcionalidade mais solicitada pela diretoria é confusa e ignorada pelos usuários. Como você comunica esses dados aos stakeholders?")
        Evite perguntas de sim/não e perguntas genéricas que serviriam para \
        qualquer vaga de tecnologia. Escreva no tom de uma conversa real de \
        entrevista, não como uma prova escrita. Além disso, não repita perguntas na mesma sessão.
        """,
        .count(3)
    )
    let technicalQuestions: [String]

    @Guide(
        description: """
        Gere 3 perguntas pedindo que o candidato conte sobre uma decisão de \
        projeto, arquitetura ou experiência real — no estilo "me conte sobre \
        uma vez que..." ou "descreva uma decisão que você tomou e por quê". \
        Sempre que possível, direcione o tema da pergunta para algo coerente \
        com a descrição da vaga (ex: se a vaga menciona escalabilidade, peça \
        uma decisão relacionada a performance ou arquitetura. Evite perguntas que peçam apenas uma definição \
        teórica — o objetivo é fazer o candidato narrar uma experiência \
        Além disso, não repita perguntas na mesma sessão.
        """,
        .count(3)
    )
    let projectDecisionQuestions: [String]
}

@MainActor
protocol QuestionGenerationServiceProtocol {
    
    var tokenUsagePercent: Int { get }

// Verifica se o modelo está disponível pro iOS da pessoa
    var availabilityMessage: String? { get }

//     Gera novas perguntas, evitando as que já foram geradas anteriormente
    func generateQuestions(
        for jobDescription: String,
        avoiding previousQuestions: [String]
    ) async throws -> [String]

//    Reinicia a sessão, resetando os tokens da janela de contexto
    func reset()
}

@MainActor
final class FoundationQuestionGenerationService: QuestionGenerationServiceProtocol {
    private let model = SystemLanguageModel.default
    private let instructions: String
    private var session: LanguageModelSession
    
// Responsável pela geração de perguntas diferentes
    private let options = GenerationOptions(
        sampling: .random(probabilityThreshold: 0.95),
        temperature: 0.9
    )

//    Estimativa do uso de tokens na sessão
    private var usedTokens = 0
    private var instructionsTokens: Int?

    var tokenUsagePercent: Int {
        let contextSize = model.contextSize
        guard contextSize > 0 else { return 0 }
        let fraction = Double(usedTokens) / Double(contextSize)
        return min(100, max(0, Int((fraction * 100).rounded())))
    }

    var availabilityMessage: String? {
        switch model.availability {
        case .available:
            return nil
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Ative o Apple Intelligence nos Ajustes para gerar as perguntas."
        case .unavailable(.deviceNotEligible):
            return "Este dispositivo não é compatível com o Apple Intelligence."
        case .unavailable(.modelNotReady):
            return "O modelo ainda está sendo preparado. Tente novamente em instantes."
        case .unavailable:
            return "O modelo de IA não está disponível neste dispositivo."
        }
    }

    init() {
        instructions = """
        Você é um entrevistador experiente que adapta as perguntas à ÁREA da vaga. \
        Antes de gerar, identifique a área a partir da descrição (ex.: design/UX, \
        produto, dados, engenharia de software, marketing, etc.) e permaneça \
        estritamente nessa área. NÃO introduza temas de programação, APIs ou \
        arquitetura de software a menos que a descrição os mencione explicitamente — \
        por exemplo, numa vaga de design, pergunte sobre processo de design, \
        pesquisa com usuários, design systems, prototipação e usabilidade, não sobre \
        código. Gere perguntas realistas, específicas e variadas, ancoradas \
        exclusivamente no que a descrição realmente menciona; evite perguntas \
        genéricas que serviriam para qualquer vaga.
        """
        session = LanguageModelSession(instructions: instructions)
    }

    func generateQuestions(
        for jobDescription: String,
        avoiding previousQuestions: [String]
    ) async throws -> [String] {
        do {
            return try await respond(
                jobDescription: jobDescription,
                previousQuestions: previousQuestions,
                includeAvoidList: false
            )
        } catch let error as LanguageModelSession.GenerationError {
            // Contexto (tokens) esgotado após várias recargas: reinicia a sessão
            // e tenta de novo, enviando as perguntas anteriores para evitar repetições.
            guard case .exceededContextWindowSize = error else { throw error }
            reset()
            return try await respond(
                jobDescription: jobDescription,
                previousQuestions: previousQuestions,
                includeAvoidList: true
            )
        }
    }

    func reset() {
        session = LanguageModelSession(instructions: instructions)
        usedTokens = instructionsTokens ?? 0
    }

    private func respond(
        jobDescription: String,
        previousQuestions: [String],
        includeAvoidList: Bool
    ) async throws -> [String] {
        let prompt = makePrompt(
            jobDescription: jobDescription,
            previousQuestions: previousQuestions,
            includeAvoidList: includeAvoidList
        )

        let response = try await session.respond(
            to: prompt,
            generating: GeneratedInterview.self,
            options: options
        )

        // Ordem de exibição: primeiro as perguntas de decisão de projeto,
        // depois as técnicas.
        let content = response.content
        let questions = content.projectDecisionQuestions + content.technicalQuestions

        await updateTokenUsage(prompt: prompt, questions: questions)
        return questions
    }

    private func makePrompt(
        jobDescription: String,
        previousQuestions: [String],
        includeAvoidList: Bool
    ) -> String {
        if previousQuestions.isEmpty {
            return "Gere as perguntas de entrevista para esta vaga:\n\(jobDescription)"
        }

        if includeAvoidList {
            // Sessão recém-reiniciada: sem memória do que já foi perguntado, então
            // listamos explicitamente as perguntas a evitar (limitado para poupar tokens).
            let avoid = previousQuestions
                .suffix(30)
                .map { "- \($0)" }
                .joined(separator: "\n")

            return """
            Gere novas perguntas de entrevista para esta vaga, diferentes das anteriores. \
            Não repita nem reformule nenhuma destas:
            \(avoid)

            Descrição da vaga:
            \(jobDescription)
            """
        }

        // Mesma sessão: o modelo lembra o que já perguntou nesta conversa,
        // então basta um prompt curto (economiza tokens do contexto).
        return "Gere novas perguntas de entrevista para a mesma vaga, completamente diferentes das que você já fez nesta conversa."
    }

    private func updateTokenUsage(prompt: String, questions: [String]) async {
        if instructionsTokens == nil {
            let count = await tokenCount(of: instructions)
            instructionsTokens = count
            usedTokens += count
        }

        usedTokens += await tokenCount(of: prompt)
        usedTokens += await tokenCount(of: questions.joined(separator: "\n"))
    }

// Estimativa de mais ou menos 4 caracteres por tokens
    private func tokenCount(of text: String) async -> Int {
        if #available(iOS 26.4, *) {
            if let count = try? await model.tokenCount(for: text) {
                return count
            }
        }
        return max(1, Int((Double(text.count) / 4.0).rounded(.up)))
    }
}
