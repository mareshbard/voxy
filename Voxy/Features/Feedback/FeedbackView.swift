//
//  FeedbackView.swift
//  Voxy
//
//  Created by Voxy Team on 01/09/26.
//

import SwiftUI

struct FeedbackView: View {
    @State private var viewModel: FeedbackViewModel
    
    init(engine: FeedbackEngineProtocol? = nil) {
        _viewModel = State(initialValue: FeedbackViewModel(engine: engine))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Alerta de Disponibilidade do Apple Intelligence (se indisponível ou em preparação)
                    if let availabilityMessage = viewModel.availabilityMessage {
                        availabilityBanner(message: availabilityMessage)
                    }
                    
                    // Form de Entrada da Pergunta e Resposta
                    inputSection
                    
                    // Alerta de Erro
                    if let errorMessage = viewModel.errorMessage {
                        errorBanner(message: errorMessage)
                    }
                    
                    // Estado de Carregamento
                    if viewModel.isLoading {
                        loadingView
                    }
                    
                    // Card do Feedback Gerado
                    if let feedback = viewModel.feedback, !viewModel.isLoading {
                        feedbackResultsSection(feedback: feedback)
                    }
                }
                .padding()
            }
            .navigationTitle("Feedback de Fala")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Pergunta da Entrevista (Opcional)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Ex: Conte sobre uma decisão técnica difícil que você tomou.", text: $viewModel.question, axis: .vertical)
                    .lineLimit(2...4)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Resposta Transcrita")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("Carregar Exemplo") {
                        loadExampleData()
                    }
                    .font(.caption)
                    .bold()
                }
                
                TextEditor(text: $viewModel.answer)
                    .frame(minHeight: 130)
                    .padding(8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            
            Button {
                Task {
                    await viewModel.analyze()
                }
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Gerar Feedback com IA")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canAnalyze ? Color.accentColor : Color.gray.opacity(0.4))
                .cornerRadius(12)
            }
            .disabled(!viewModel.canAnalyze)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Feedback Results Section
    private func feedbackResultsSection(feedback: AnswerFeedback) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Análise On-Device")
                .font(.title2)
                .bold()
            
            // Card de Articulação e Nota
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Clareza e Articulação")
                        .font(.headline)
                    Spacer()
                    scoreBadge(score: feedback.articulationScore)
                }
                
                Text(feedback.articulationNotes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Vícios de Linguagem / Muletas
                if !feedback.languageVices.isEmpty {
                    Divider().padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Vícios de Linguagem Encontrados:")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.orange)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(feedback.languageVices, id: \.self) { vice in
                                Text("\"\(vice)\"")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Pontos Técnicos Fortes
            if !feedback.technicalStrengths.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Pontos Fortes Demonstrados", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    ForEach(feedback.technicalStrengths, id: \.self) { strength in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .padding(.top, 2)
                            Text(strength)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Lacunas Técnicas / Sugestões
            if !feedback.technicalGaps.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Sugestões de Estudo & Melhoria", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ForEach(feedback.technicalGaps, id: \.self) { gap in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "book.fill")
                                .foregroundColor(.blue)
                                .font(.subheadline)
                                .padding(.top, 2)
                            Text(gap)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            
            // Resumo Acionável
            VStack(alignment: .leading, spacing: 8) {
                Label("Resumo Acionável", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Text(feedback.summary)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.08))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.purple.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Subviews & Helpers
    
    private func scoreBadge(score: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= score ? "star.fill" : "star")
                    .foregroundColor(index <= score ? .yellow : .gray.opacity(0.3))
                    .font(.caption)
            }
            Text("\(score)/5")
                .font(.caption)
                .bold()
                .padding(.leading, 4)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Sintetizando feedback on-device...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
    
    private func availabilityBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.15))
        .cornerRadius(10)
    }
    
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "xmark.octagon.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.15))
        .cornerRadius(10)
    }
    
    private func loadExampleData() {
        viewModel.question = "Como você lidaria com um incidente de queda em ambiente de produção?"
        viewModel.answer = "Bom, tipo, assim que o alerta bate no Slack né, eu correria pra olhar os logs no CloudWatch, daí tipo assim, tentaria fazer um rollback rápido do último deploy pra estabilizar o sistema antes de investigar a fundo."
    }
}

// MARK: - Custom FlowLayout para Tag Badges
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.bounds
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(
                x: bounds.minX + result.offsets[index].x,
                y: bounds.minY + result.offsets[index].y
            )
            subview.place(at: point, proposal: .unspecified)
        }
    }

    struct FlowResult {
        var offsets: [CGPoint] = []
        var bounds: CGSize = .zero

        init(in maxLineWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxLineWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                offsets.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
                bounds.width = max(bounds.width, currentX)
            }

            bounds.height = currentY + lineHeight
        }
    }
}

// MARK: - Mock para Previews do Xcode
final class MockFeedbackEngine: FeedbackEngineProtocol {
    var availabilityMessage: String? = nil
    
    func evaluate(question: String, answer: String) async throws -> AnswerFeedback {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        return AnswerFeedback(
            articulationScore: 4,
            articulationNotes: "A resposta foi clara e apresentou uma estratégia prática de contenção de danos, porém contou com algumas hesitações e termos repetitivos.",
            languageVices: ["tipo", "né", "tipo assim", "daí"],
            technicalStrengths: [
                "Uso correto de observabilidade (CloudWatch e alertas Slack)",
                "Foco em mitigar o impacto rápido via Rollback"
            ],
            technicalGaps: [
                "Estudar protocolos de comunicação com stakeholders durante incidentes",
                "Mencionar análise de causa raiz (RCA) e Post-Mortem após a contenção"
            ],
            summary: "A resposta técnica é sólida. Foque em eliminar as palavras de transição ('tipo', 'né') para demonstrar mais senioridade e segurança."
        )
    }
}

#Preview {
    FeedbackView(engine: MockFeedbackEngine())
}

