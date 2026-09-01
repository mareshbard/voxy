//
//  QuestionGenerationService.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import Foundation
import FoundationModels

/// Formato de saída esperado do modelo ao gerar uma entrevista.
@Generable
struct GeneratedInterview {
    @Guide(
        description: "Faça 10 perguntas de entrevista técnica, específicas para a vaga descrita, evitando perguntas genéricas que serviriam para qualquer vaga.",
        .count(10)
    )
    let questions: [String]
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
        Você é um entrevistador técnico experiente em tecnologia e design. \
        Gere perguntas de entrevista realistas, específicas e variadas, baseadas \
        exclusivamente na descrição da vaga fornecida pelo usuário. Evite perguntas \
        genéricas que serviriam para qualquer vaga — ancore cada pergunta em algo \
        que a descrição realmente menciona.
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
        let questions = response.content.questions

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
            Gere 10 novas perguntas de entrevista para esta vaga, diferentes das anteriores. \
            Não repita nem reformule nenhuma destas:
            \(avoid)

            Descrição da vaga:
            \(jobDescription)
            """
        }

        // Mesma sessão: o modelo lembra o que já perguntou nesta conversa,
        // então basta um prompt curto (economiza tokens do contexto).
        return "Gere 10 novas perguntas de entrevista para a mesma vaga, completamente diferentes das que você já fez nesta conversa."
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

    /// uma estimativa de ~4 caracteres por token.
    private func tokenCount(of text: String) async -> Int {
        if #available(iOS 26.4, *) {
            if let count = try? await model.tokenCount(for: text) {
                return count
            }
        }
        return max(1, Int((Double(text.count) / 4.0).rounded(.up)))
    }
}
