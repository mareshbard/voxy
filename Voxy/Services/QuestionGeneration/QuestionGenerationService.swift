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

// Contexto completo da vaga usado para gerar as perguntas.
struct JobContext {
    let title: String
    let companyName: String
    let description: String
}

@MainActor
protocol QuestionGenerationServiceProtocol {

    var tokenUsagePercent: Int { get }

// Verifica se o modelo está disponível pro iOS da pessoa
    var availabilityMessage: String? { get }

//     Gera novas perguntas, evitando as que já foram geradas anteriormente
    func generateQuestions(
        for job: JobContext,
        avoiding previousQuestions: [String]
    ) async throws -> [String]

//    Reinicia a sessão, resetando os tokens da janela de contexto
    func reset()

//    Pré-carrega o modelo para reduzir a latência da primeira geração
    func prewarm()
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
        let estimatedContextSize = 4096

        let fraction = Double(usedTokens) / Double(estimatedContextSize)

        return min(
            100,
            max(0, Int((fraction * 100).rounded()))
        )
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

    func prewarm() {
        session.prewarm()
    }

    func generateQuestions(
        for job: JobContext,
        avoiding previousQuestions: [String]
    ) async throws -> [String] {
        do {
            return try await respond(
                job: job,
                previousQuestions: previousQuestions
            )
        } catch let error as LanguageModelSession.GenerationError {
            // Contexto (tokens) esgotado após várias recargas: reinicia a sessão
            // e tenta de novo. As perguntas anteriores são reenviadas no prompt.
            guard case .exceededContextWindowSize = error else { throw error }
            reset()
            return try await respond(
                job: job,
                previousQuestions: previousQuestions
            )
        }
    }

    func reset() {
        session = LanguageModelSession(instructions: instructions)
        usedTokens = instructionsTokens ?? 0
    }

    private func respond(
        job: JobContext,
        previousQuestions: [String]
    ) async throws -> [String] {
        let prompt = makePrompt(
            job: job,
            previousQuestions: previousQuestions
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

        // Rede de segurança: mesmo instruído a não repetir, o modelo pode
        // reformular uma pergunta antiga. Removemos duplicatas (contra o
        // histórico e dentro do próprio lote) para garantir que nunca se repitam.
        return deduplicated(questions, avoiding: previousQuestions)
    }

    private func makePrompt(
        job: JobContext,
        previousQuestions: [String]
    ) -> String {
        // Bloco de contexto da vaga (cargo, empresa e descrição) para ancorar
        // melhor as perguntas.
        let jobBlock = """
        Cargo: \(job.title)
        Empresa: \(job.companyName)
        Descrição da vaga:
        \(job.description)
        """

        guard !previousQuestions.isEmpty else {
            return "Gere as perguntas de entrevista para esta vaga:\n\(jobBlock)"
        }

        // Uma sessão nova (outro treino ou nova abertura do app) não tem memória
        // do que já foi perguntado em treinos passados, então listamos
        // explicitamente as perguntas a evitar (limitado para poupar tokens).
        let avoid = previousQuestions
            .suffix(40)
            .map { "- \($0)" }
            .joined(separator: "\n")

        return """
        Gere novas perguntas de entrevista para esta vaga, completamente diferentes das anteriores. \
        Não repita nem reformule nenhuma destas perguntas já feitas:
        \(avoid)

        \(jobBlock)
        """
    }

    // Remove perguntas que repetem (ignorando maiúsculas, acentos e pontuação)
    // qualquer uma do histórico ou uma anterior do mesmo lote.
    private func deduplicated(
        _ questions: [String],
        avoiding previous: [String]
    ) -> [String] {
        var seen = Set(previous.map(normalizedKey))
        var result: [String] = []

        for question in questions {
            let key = normalizedKey(question)
            guard !key.isEmpty, !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(question)
        }

        return result
    }

    private func normalizedKey(_ text: String) -> String {
        text
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
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
        max(
            1,
            Int((Double(text.count) / 4.0).rounded(.up))
        )
    }
}
