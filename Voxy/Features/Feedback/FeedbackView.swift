import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FeedbackViewModel
    //@State private var goHome = false

    init(engine: (FeedbackEngineProtocol & FinalFeedbackProtocol)? = nil, question: String, feedbacks: [AnswerFeedback] = []) {
        _viewModel = State(initialValue: FeedbackViewModel(engine: engine))
        _viewModel.wrappedValue.question = question
        _viewModel.wrappedValue.feedbacks = feedbacks
    }

    var body: some View {
            ScrollView {
                VStack {
                    VStack {
                        Text("Mandou bem!")
                            .font(Font.custom("Nunito", size: 28)
                                .weight(.bold))
                        Text("Você está arrasando!")
                        VStack {
                            Text("JÁ TREINOU")
                                .font(Font.custom("Nunito", size: 11)
                                    .weight(.bold))
                            Text("15")
                            Text("vezes!")
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(24)
                    }


                    if viewModel.isLoading {
                        ProgressView("Gerando feedback...")
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
//        .navigationDestination(isPresented: $goHome) {
//            OnBoardingView(feedbackEngine: FoundationFeedbackEngine())
//        }
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Button(action: { goHome = true }) {
//                    Label("Início", systemImage: "house")
//                }
//            }
//        }
        .scrollIndicators(.hidden)
        .task {
            await viewModel.analyzeFinal()
        }
    }

}

#Preview {
    FeedbackView(question: "")
}
