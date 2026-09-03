//
//  InterviewView.swift
//  Voxy
//
//  Created by Voxy Team on 31/08/26.
//

import SwiftUI

struct InterviewView: View {
    @State private var viewModel: InterviewViewModel

    init(jobPosting: JobPosting) {
        _viewModel = State(initialValue: InterviewViewModel(jobPosting: jobPosting))
    }

    var body: some View {
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
    }
}

#Preview {
    NavigationStack {
        InterviewView(
            jobPosting: JobPosting(
                title: "iOS Engineer",
                companyName: "Nubank",
                jobDescription: "Experiência com Swift, SwiftUI, testes unitários e CI/CD."
            )
        )
    }
}
