import SwiftUI

struct FeedbackView: View {
    @State private var viewModel: FeedbackViewModel
    
    init(engine: FeedbackEngineProtocol? = nil, question: String) {
        _viewModel = State(initialValue: FeedbackViewModel(engine: engine))
        _viewModel.wrappedValue.question = question
    }
    
    var body: some View {
        ScrollView {
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
            
            Section(header:
                        Text("MELHORES MOMENTOS")
                .foregroundColor(.gray) // Muda a cor
                .font(.caption)
                .padding(.leading, 20) // Muda a posição (ajusta o recuo esquerdo)
                .frame(maxWidth: .infinity, alignment: .leading) // Alinha o texto dentro do espaço disponível
            ) {
                ForEach(viewModel.feedback?.technicalStrengths ?? [], id: \.self) { moment in
                   Text(moment)
                }
                ForEach(viewModel.feedback?.technicalGaps ?? [], id: \.self) { moment in
                   Text(moment)
                }
            }
        }
    }
}

#Preview {
    FeedbackView(question: "")
}
