import SwiftUI
import SwiftData

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: FeedbackViewModel
    @State private var goHome = false
    var job: JobPosting

    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil, question: String, feedbacks: [AnswerFeedback] = [], answers: [String] = [], job: JobPosting) {
        _viewModel = State(initialValue: FeedbackViewModel(job: job, engine: engine))
        _viewModel.wrappedValue.question = question
        _viewModel.wrappedValue.feedbacks = feedbacks
        _viewModel.wrappedValue.answers = answers
        self.job = job
    }
    
    private var isGeneratingFeedback: Bool {
        viewModel.hasAnswers && viewModel.finalFeedback == nil && viewModel.errorMessage == nil
    }

    var body: some View {
        Group {
            if isGeneratingFeedback {
                LoadingFeedbackView()
            } else {
                resultsView
            }
        }
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
                    .foregroundStyle(Color(.fbText))
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
        .onAppear {
            viewModel.saveLastFeedback()
        }
        .navigationDestination(isPresented: $goHome) {
            JobPostingListView(
                viewModel: JobPostingListViewModel(
                    store: JobPostingStore(modelContext: modelContext)
                )
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    goHome = true
                }) {
                    Label("Início", systemImage: "xmark")
                }
            }
        }
        .scrollIndicators(.hidden)
        .task {
            await viewModel.analyzeFinal()
        }
    }
}

#Preview {
    FeedbackView(question: "", job: JobPosting(title: "Dev Web", companyName: "LIT", jobDescription: "NextJS, NestJS", status: .saved, lastSimulated: Date()))
}
