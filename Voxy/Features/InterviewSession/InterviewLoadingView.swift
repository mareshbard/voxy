//
//  InterviewLoadingView.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct InterviewLoadingView: View {
    @State private var viewModel: InterviewViewModel
    @State private var feedbackEngine: FeedbackEngineProtocol
    @Environment(\.dismiss) private var dismiss
    // Encerra todo o fluxo de entrevista e volta à tela inicial.
    private let onFinish: () -> Void

    init(
        jobPosting: JobPosting,
        feedbackEngine: FeedbackEngineProtocol? = nil,
        onFinish: @escaping () -> Void = {}
    ) {
        _viewModel = State(
            initialValue: InterviewViewModel(jobPosting: jobPosting)
        )
        _feedbackEngine = State(
            initialValue: feedbackEngine ?? FoundationFeedbackEngine()
        )
        self.onFinish = onFinish
    }

    var body: some View {
        Group {
            if viewModel.questions.isEmpty {
                LoadingScreenView()
            } else {
                InterviewSessionView(
                    questions: viewModel.questions,
                    feedbackEngine: feedbackEngine,
                    jobPosting: viewModel.jobPosting,
                    onFinish: onFinish
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            guard viewModel.questions.isEmpty else { return }

            if let message = viewModel.availabilityMessage {
                viewModel.errorMessage = message
                return
            }

            viewModel.prewarm()
            await viewModel.generateQuestions()
        }
        .alert(
            "Erro",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            ),
            presenting: viewModel.errorMessage
        ) { _ in
            Button("Tentar novamente") {
                Task { await viewModel.generateQuestions() }
            }
            Button("Cancelar", role: .cancel) {
                dismiss()
            }
        } message: { message in
            Text(message)
        }
    }
}
