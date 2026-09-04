//
//  InterviewView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI

struct InterviewView: View {
    @State private var viewModel: InterviewViewModel
    @State private var feedbackEngine: FeedbackEngineProtocol
    @State private var isSessionActive = false

    init(jobPosting: JobPosting, feedbackEngine: FeedbackEngineProtocol) {
        _viewModel = State(initialValue: InterviewViewModel(jobPosting: jobPosting))
        _feedbackEngine = State(initialValue: feedbackEngine)
    }
    
    var body: some View {
        VStack {
        List {
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            
            if viewModel.isLoading {
                Section {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Gerando perguntas...")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if !viewModel.questions.isEmpty {
                Section {
                    ForEach(Array(viewModel.questions.enumerated()), id: \.offset) { index, question in
                        Text("\(index + 1). \(question)")
                    }
                    
                } header: {
                    Text("Perguntas")
                } footer: {
                    Text("DEBUG • Tokens utilizados: \(viewModel.tokenUsagePercent)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(viewModel.jobPosting.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Gerar novamente", systemImage: "arrow.clockwise") {
                    Task { await viewModel.generateQuestions() }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            if let message = viewModel.availabilityMessage {
                viewModel.errorMessage = message
                return
            }
            await viewModel.generateQuestions()
        }
            // passando perguntas geradas para a tela de entrevista
            Button {
                isSessionActive = true
            } label: {
                Text("Começar entrevista")
            }
            .disabled(viewModel.questions.isEmpty || viewModel.isLoading)
            // navegacao lazy: só renderiza quando necessário
            .navigationDestination(isPresented: $isSessionActive) {
                InterviewSessionView(questions: viewModel.questions, feedbackEngine: feedbackEngine)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InterviewView(
            jobPosting: JobPosting(
                title: "iOS Engineer",
                companyName: "Nubank",
                jobDescription: "Experiência com Swift, SwiftUI, testes unitários e CI/CD."
            ),
            feedbackEngine: FoundationFeedbackEngine()
        )
    }
}
