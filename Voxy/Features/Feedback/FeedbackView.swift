import SwiftUI
import SwiftData

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel
    var job: JobPosting
    // Fecha o feedback e volta à tela inicial (JobPostingListView).
    private let onClose: () -> Void

    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil, question: String, feedbacks: [AnswerFeedback] = [], answers: [String] = [], job: JobPosting, onClose: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: FeedbackViewModel(job: job, engine: engine))
        _viewModel.wrappedValue.question = question
        _viewModel.wrappedValue.feedbacks = feedbacks
        _viewModel.wrappedValue.answers = answers
        self.job = job
        self.onClose = onClose
    }
    
    /// Mostra a tela de carregamento desde antes de começar até a geração do
    /// feedback final terminar por completo (enquanto `isLoading` for verdadeiro
    /// ou ainda não houver resultado), sem erro.
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
        ScrollView {
            VStack {
                VStack {
                    Image(viewModel.headerMascotImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 100)
                        .padding(.bottom, 4)

                    Text(viewModel.headerTitle)
                        .font(.custom("Satoshi-Bold", size: 32))
                        .bold()

                    Text(viewModel.headerSubtitle)
                        .font(Font.custom("Nunito", size: 20).weight(.bold))
                        .multilineTextAlignment(.center)

                    VStack {
                        Text("JÁ TREINOU")
                            .font(Font.custom("Satoshi-Bold", size: 12).weight(.bold))
                        Text("\(job.countInterview)")
                            .font(Font.custom("Nunito", size: 24).weight(.bold))
                            .foregroundStyle(Color(.total))
                        Text(job.countInterview == 1 ? "vez!" : "vezes!")
                            .font(Font.custom("Nunito", size: 14).weight(.bold))
                    }
                    
                    .accessibilityElement(children: .combine)
                    .padding(16)
                    //.frame(width: 120, height: 100)
                    .foregroundStyle(Color("PrimaryFontColor"))
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("PrimaryBlue"))
                            
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("BackgroundJobCardColor"))
                                .offset(x: -5, y: -5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color("PrimaryBlue"), lineWidth: 1)
                    )
                }
                
                Spacer(minLength: 25)
                
                if !viewModel.hasAnswers {
                    VStack(spacing: 8) {
                        Text("Não há nada para analisar")
                            .font(.custom("Satoshi-Bold", size: 18))
                        Text("Responda ao menos uma pergunta em voz alta para receber seu feedback.")
                            .font(Font.custom("Nunito", size: 16).weight(.bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                } else if let final = viewModel.finalFeedback {
                    FeedbackSection(title: "CLAREZA", items: final.clarity, highlighted: true)
                    FeedbackSection(title: "VÍCIOS", items: final.vicios, highlighted: true)
                    FeedbackSection(title: "PROFUNDIDADE", items: final.profundity, highlighted: true)
                    FeedbackSection(title: "MELHORES MOMENTOS", items: final.bestMoments)
                    FeedbackSection(title: "ONDE MELHORAR", items: final.improve)
                }
            }
            .padding(24)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.saveLastFeedback()
        }
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
}

#Preview {
    FeedbackView(question: "", job: JobPosting(title: "Dev Web", companyName: "LIT", jobDescription: "NextJS, NestJS", status: .saved, lastSimulated: Date()))
}
