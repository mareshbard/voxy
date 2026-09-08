//
//  FeedbackViewModel.swift
//  Voxy
//
//  Created by Voxy Team on 01/09/26.
//

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
    
    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil) {
        self.engine = engine ?? FoundationFeedbackEngine()
    }

    var availabilityMessage: String? {
        engine.availabilityMessage
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
            finalFeedback = try await engine.evaluate(feedbacks: joined)
        } catch {
            errorMessage = "Erro ao gerar feedback final: \(error.localizedDescription)"
        }
    }
    // MARK: Funções para a tela de feedback
    
    var bestMoments: [String] {
        feedback?.technicalStrengths ?? []
    }
    
    var improvementSuggestions: [String] {
        feedback?.technicalGaps ?? []
    }
    
}
