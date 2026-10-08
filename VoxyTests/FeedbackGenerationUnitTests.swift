//
//  FeedbackGenerationUnitTests.swift
//  Voxy
//
//  Created by Voxy Team on 08/10/26.
//

import Testing
@testable import Voxy

@MainActor
struct FeedbackGenerationUnitTests {

    // CT-35 — Feedback gerado com sucesso
    @Test
    func successfulFeedbackGenerationAddsFeedback() async {
        let service = MockFeedbackEngine()
        let expectedFeedback = AnswerFeedback(
            articulationScore: 4,
            articulationNotes: "Resposta clara e bem estruturada.",
            languageVices: [],
            technicalStrengths: ["Conhecimento de Swift"],
            technicalGaps: ["Aprofundar SwiftUI"],
            summary: "Boa resposta técnica."
        )
        service.feedback = expectedFeedback

        let viewModel = makeViewModel(feedbackEngine: service)
        viewModel.speechAnalyzerManager.transcript =
            "Tenho experiência com Swift e desenvolvimento de aplicativos iOS."

        await viewModel.finishCurrentQuestion()

        #expect(viewModel.feedbacks.count == 1)
        #expect(viewModel.feedbacks.first == expectedFeedback)
    }

    // CT-36 — Falha na geração de feedback
    @Test
    func feedbackGenerationFailureDoesNotAddFeedback() async {
        let service = MockFeedbackEngine()
        service.shouldThrowError = true

        let viewModel = makeViewModel(feedbackEngine: service)
        viewModel.speechAnalyzerManager.transcript =
            "Tenho experiência com Swift e desenvolvimento de aplicativos iOS."

        await viewModel.finishCurrentQuestion()

        #expect(viewModel.feedbacks.isEmpty)
    }

    private func makeViewModel(
        feedbackEngine: FeedbackEngineProtocol
    ) -> InterviewSessionViewModel {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Voxy",
            jobDescription: "Desenvolvimento de aplicações iOS."
        )

        return InterviewSessionViewModel(
            questions: ["Por que você quer trabalhar com iOS?"],
            feedbackEngine: feedbackEngine,
            jobPosting: jobPosting
        )
    }
}

@MainActor
private final class MockFeedbackEngine: FeedbackEngineProtocol {

    var availabilityMessage: String?
    var feedback: AnswerFeedback?
    var shouldThrowError = false

    func evaluate(
        question: String,
        answer: String
    ) async throws -> AnswerFeedback {
        if shouldThrowError {
            throw MockFeedbackError.generationFailed
        }

        return feedback!
    }
}

private enum MockFeedbackError: Error {
    case generationFailed
}
