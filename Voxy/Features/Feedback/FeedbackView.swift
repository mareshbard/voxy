import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel
    @State private var goHome = false
    // private let interviewCount: Int
    var job: JobPosting
    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil, question: String, feedbacks: [AnswerFeedback] = [], job: JobPosting) {
        _viewModel = State(initialValue: FeedbackViewModel(job: job, engine: engine))
        _viewModel.wrappedValue.question = question
        _viewModel.wrappedValue.feedbacks = feedbacks
        self.job = job
    }
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("Mandou bem!")
                        .font(.custom("Satoshi-Bold", size: 32))
                        .bold()
                    Text("Você está arrasando!")
                        .font(Font.custom("Nunito", size: 20)
                            .weight(.bold))
                    VStack {
                        Text("JÁ TREINOU")
                            .font(Font.custom("Satoshi-Bold", size: 12)
                                .weight(.bold))
                        Text("\(job.countInterview)")
                            .font(Font.custom("Nunito", size: 24)
                                .weight(.bold))
                            .foregroundStyle(Color(.total))
                        Text(job.countInterview == 1 ? "vez!" : "vezes!")
                            .font(Font.custom("Nunito", size: 14)
                                .weight(.bold))
                    }
                    .padding(16)
                    .frame(width: 120, height: 100) // Dimensões do cartão
                    .background(Color(.fbBg))
                    .cornerRadius(24)
                    .foregroundStyle(Color(.fbText))
                }
                
                Spacer(minLength: 25)
                
                if viewModel.isLoading {
                    ProgressView("Analisando entrevista...")
                        .padding()
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
            OnBoardingView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    goHome = true // Ativa a navegação para a home
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
