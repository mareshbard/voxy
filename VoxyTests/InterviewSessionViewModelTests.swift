//
//  InterviewSessionViewModelTests.swift
//  Voxy
//
//  Created by Voxy Team on 18/09/26.
//

import Testing
import Foundation
@testable import Voxy

@MainActor
struct InterviewSessionViewModelTests {

    final class MockFeedbackEngine: FeedbackEngineProtocol {
        var availabilityMessage: String? = nil

        func evaluate(
            question: String,
            answer: String
        ) async throws -> AnswerFeedback {
            AnswerFeedback(
                articulationScore: 4,
                articulationNotes: "Resposta clara.",
                languageVices: [],
                technicalStrengths: ["Demonstrou conhecimento técnico."],
                technicalGaps: ["Pode aprofundar a resposta.", "Pode fornecer exemplos."],
                summary: "Boa resposta."
            )
        }
    }

    // CT-07
    @Test
    func completedTrainingWithFeedbackIncrementsInterviewCount() async {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS."
        )

        let initialCount = jobPosting.countInterview

        let viewModel = InterviewSessionViewModel(
            questions: ["O que é SwiftUI?"],
            feedbackEngine: MockFeedbackEngine(),
            jobPosting: jobPosting
        )

        viewModel.speechAnalyzerManager.transcript =
            "SwiftUI é um framework declarativo para construção de interfaces."

        await viewModel.advance()

        #expect(viewModel.feedbacks.count == 1)
        #expect(jobPosting.countInterview == initialCount + 1)
    }
    
    // CT-08
    @Test
    func completedTrainingWithoutFeedbackDoesNotIncrementInterviewCount() async {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS."
        )

        let initialCount = jobPosting.countInterview

        let viewModel = InterviewSessionViewModel(
            questions: ["O que é SwiftUI?"],
            feedbackEngine: MockFeedbackEngine(),
            jobPosting: jobPosting
        )

        viewModel.speechAnalyzerManager.transcript = ""

        await viewModel.advance()

        #expect(viewModel.feedbacks.isEmpty)
        #expect(jobPosting.countInterview == initialCount)
    }
    
    // CT-09
    @Test
    func completedTrainingRecordsUsedQuestions() async {
        let jobPosting = JobPosting(
            title: "iOS Developer",
            companyName: "Empresa",
            jobDescription: "Desenvolvimento de aplicações iOS."
        )

        let questions = ["O que é SwiftUI?"]

        let viewModel = InterviewSessionViewModel(
            questions: questions,
            feedbackEngine: MockFeedbackEngine(),
            jobPosting: jobPosting
        )

        viewModel.speechAnalyzerManager.transcript =
            "SwiftUI é um framework declarativo para construção de interfaces."

        await viewModel.advance()

        #expect(viewModel.feedbacks.count == 1)
        #expect(jobPosting.askedQuestions.contains("O que é SwiftUI?"))
    }
}
