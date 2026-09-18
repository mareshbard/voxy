import SwiftUI
import SwiftData

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel
    var job: JobPosting
    // Fecha o feedback e volta à tela inicial (JobPostingListView).
    private let onClose: () -> Void
    // Altura real do header, usada para dimensionar a faixa azul do topo.
    @State private var headerHeight: CGFloat = 300
    // Dispara uma nova entrevista para a mesma vaga.
    @State private var restartInterview = false

    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil, question: String, feedbacks: [AnswerFeedback] = [], answers: [String] = [], job: JobPosting, onClose: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: FeedbackViewModel(job: job, engine: engine))
        _viewModel.wrappedValue.question = question
        _viewModel.wrappedValue.feedbacks = feedbacks
        _viewModel.wrappedValue.answers = answers
        self.job = job
        self.onClose = onClose
    }
    
    private var isGeneratingFeedback: Bool {
        guard viewModel.hasAnswers, viewModel.errorMessage == nil else { return false }
        return viewModel.isLoading || viewModel.finalFeedback == nil
    }

    var body: some View {
        Group {
            if isGeneratingFeedback {
                LoadingFeedbackView()
            } else {
                resultsView
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.analyzeFinal()
        }
    }

    private var resultsView: some View {
        ZStack(alignment: .top) {
            // Fundo base da tela (cobre o overscroll inferior).
            Color("VoxyBackground")
                .ignoresSafeArea()

            // Faixa azul fixa no topo, para cobrir o overscroll (quando o usuário
            // puxa a tela) e a área da navbar. A altura acompanha o header real.
            Color("PrimaryBlue")
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: HeaderHeightPreferenceKey.self,
                                    value: proxy.size.height
                                )
                            }
                        )
                    VStack(spacing: 16) {
                        CounterCard(job: viewModel.job)

                        if !viewModel.hasAnswers {
                            noAnswersView
                        } else if let final = viewModel.finalFeedback {
                            sections(for: final)
                        }

                        Button("Treinar de novo") {
                            restartInterview = true
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(BlueGameButton())
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                    .background(Color("VoxyBackground"))
                }
            }
            .scrollIndicators(.hidden)
            .onPreferenceChange(HeaderHeightPreferenceKey.self) { newHeight in
                headerHeight = newHeight
            }
        }
        .onAppear {
            viewModel.saveLastFeedback()
        }
        .navigationDestination(isPresented: $restartInterview) {
            // Gera uma nova entrevista para a mesma vaga; ao finalizar, fecha o fluxo.
            InterviewLoadingView(jobPosting: viewModel.job, onFinish: onClose)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    onClose()
                }) {
                    Label("Início", systemImage: "xmark")
                }
            }
        }
    }

    // Header com fundo azul que sangra até as bordas e o topo, como nas outras telas.
    private var header: some View {
        VStack(spacing: 8) {
            Image(viewModel.headerMascotImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 100)
                .padding(.bottom, 4)
                .accessibilityLabel(Text(viewModel.miaDescription))

            Text(viewModel.headerTitle)
                .font(.custom("Satoshi-Bold", size: 32))
                .bold()
                .foregroundStyle(.white)

            Text(viewModel.headerSubtitle)
                .font(Font.custom("Nunito", size: 20).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)

            
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background(
            Color("PrimaryBlue")
                .ignoresSafeArea(edges: .top)
        )
    }

    private var noAnswersView: some View {
        // O mascote já aparece no header (dentro da faixa azul); aqui fica só o texto.
        VStack(spacing: 8) {
            Text("Não há nada para analisar")
                .font(.custom("Satoshi-Bold", size: 18))
            Text("Responda ao menos uma pergunta em voz alta para receber seu feedback.")
                .font(Font.custom("Nunito", size: 16).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 20)
    }

    @ViewBuilder
    private func sections(for final: FinalFeedback) -> some View {
        FeedbackSection(
            title: "CLAREZA",
            items: final.clarity,
            highlighted: true,
            rating: .forScore(Double(final.clarityScore))
        )
        FeedbackSection(
            title: "VÍCIOS",
            items: final.vicios,
            highlighted: true,
            rating: .forVices(count: final.vicios.count)
        )
        FeedbackSection(
            title: "PROFUNDIDADE",
            items: final.profundity,
            highlighted: true,
            rating: .forScore(Double(final.profundityScore))
        )
        FeedbackSection(
            title: "MELHORES MOMENTOS",
            items: final.bestMoments,
            mascotImageName: "MiaFeedbackLike",
            mascotPlacement: .leading
        )
        FeedbackSection(
            title: "ONDE MELHORAR",
            items: final.improve,
            mascotImageName: "MiaFeedbackClipboard",
            mascotPlacement: .trailing
        )
    }
}

#if DEBUG
// Engine falso só para o Preview: retorna dados fixos, sem depender do modelo on-device.
@MainActor
private final class PreviewFeedbackEngine: FeedbackEngineProtocol, FinalFeedbackProtocol {
    var availabilityMessage: String? { nil }

    func evaluate(question: String, answer: String) async throws -> AnswerFeedback {
        AnswerFeedback(
            articulationScore: 4,
            articulationNotes: "Boa articulação, com raciocínio claro.",
            languageVices: ["tipo assim"],
            technicalStrengths: ["Usou dados reais"],
            technicalGaps: ["Aprofundar métricas"],
            summary: "Bom desempenho geral."
        )
    }

    func evaluate(feedbacks: String) async throws -> FinalFeedback {
        FinalFeedback(
            improve: [
                "Detalhe melhor o processo de validação (pesquisa, testes) antes de falar do resultado.",
                "Se mencionar uma dificuldade, complete com como você lidou com ela."
            ],
            bestMoments: [
                "Você usou dados reais para sustentar o impacto do projeto, reforçando sua credibilidade.",
                "Demonstrou colaboração ao citar que trabalhou com o time de desenvolvimento."
            ],
            clarity: [
                "A ordem cronológica ajudou a seguir seu raciocínio.",
                "Em alguns momentos a ideia principal ficou um pouco diluída."
            ],
            clarityScore: 3,
            vicios: ["tipo assim", "então, tipo"],
            profundity: [
                "Você trouxe exemplos concretos que reforçaram seus argumentos.",
                "Citou a métrica de conversão, mas não explicou como chegou a esse número."
            ],
            profundityScore: 4
        )
    }
}
#endif

#Preview("Com feedback") {
    NavigationStack {
        FeedbackView(
            engine: PreviewFeedbackEngine(),
            question: "Fale sobre um projeto do qual você se orgulha.",
            feedbacks: [
                AnswerFeedback(
                    articulationScore: 4,
                    articulationNotes: "Boa articulação.",
                    languageVices: ["tipo assim"],
                    technicalStrengths: ["Usou dados reais"],
                    technicalGaps: ["Aprofundar métricas"],
                    summary: "Bom desempenho."
                )
            ],
            answers: [
                "No meu último projeto liderei a migração do sistema de pagamentos, o que aumentou a conversão em 12% ao longo de três meses."
            ],
            job: JobPosting(title: "iOS Developer", companyName: "Voxy", jobDescription: "Swift/SwiftUI", status: .saved, lastSimulated: Date())
        )
    }
}

#Preview("Sem respostas") {
    NavigationStack {
        FeedbackView(question: "", job: JobPosting(title: "Dev Web", companyName: "LIT", jobDescription: "NextJS, NestJS", status: .saved, lastSimulated: Date()))
    }
}
