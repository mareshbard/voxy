//
//  InterviewViewModelTests.swift
//  Voxy
//
//  Created by Voxy Team on 24/09/26.
//


import Testing
@testable import Voxy

@MainActor
struct InterviewViewModelTests {

    final class MockQuestionGenerationService: QuestionGenerationServiceProtocol {
        var tokenUsagePercent = 0
        var availabilityMessage: String? = nil

        var receivedJob: JobContext?
        var receivedPreviousQuestions: [String] = []
        var generateQuestionsCallCount = 0

        func generateQuestions(
            for job: JobContext,
            avoiding previousQuestions: [String]
        ) async throws -> [String] {
            generateQuestionsCallCount += 1
            receivedJob = job
            receivedPreviousQuestions = previousQuestions

            return ["Pergunta 1"]
        }

        func reset() {}

        func prewarm() {}
    }

    // CT-17
    @Test
    func generatesQuestionsWithValidJobDescription() async {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Experiência com Swift e SwiftUI."
        )

        let service = MockQuestionGenerationService()

        let viewModel = InterviewViewModel(
            jobPosting: jobPosting,
            service: service
        )

        await viewModel.generateQuestions()

        #expect(service.generateQuestionsCallCount == 1)
        #expect(service.receivedJob?.title == "iOS Developer")
        #expect(service.receivedJob?.description == "Experiência com Swift e SwiftUI.")
    }
    
    // CT-18
    @Test
    func doesNotGenerateQuestionsWithEmptyJobDescription() async {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "   "
        )

        let service = MockQuestionGenerationService()

        let viewModel = InterviewViewModel(
            jobPosting: jobPosting,
            service: service
        )

        await viewModel.generateQuestions()

        #expect(service.generateQuestionsCallCount == 0)
        #expect(viewModel.questions.isEmpty)
        #expect(
            viewModel.errorMessage ==
            "Esta vaga não tem descrição para gerar perguntas."
        )
    }
    
    // CT-19
    @Test
    func avoidsPreviouslyAskedQuestions() async {
        let previousQuestions = [
            "O que é SwiftUI?",
            "Explique o padrão MVVM."
        ]

        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Experiência com Swift e SwiftUI.",
            askedQuestions: previousQuestions
        )

        let service = MockQuestionGenerationService()

        let viewModel = InterviewViewModel(
            jobPosting: jobPosting,
            service: service
        )

        await viewModel.generateQuestions()

        #expect(service.receivedPreviousQuestions == previousQuestions)
    }
}
