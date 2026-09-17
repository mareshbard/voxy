import SwiftUI
import AVFoundation

struct InterviewSessionView: View {
    @State private var viewModel: InterviewSessionViewModel
    @State private var feedbackEngine: FeedbackEngineProtocol
    @State private var showExitConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    private let onFinish: () -> Void
    
    // Propriedades computadas para aliviar a verificação de tipos do compilador
    private var speakerImageName: String {
        viewModel.isSpeaking ? "stop.fill" : "speaker.wave.1.fill"
    }
    
    private var speakerForegroundStyle: Color {
        viewModel.isSpeaking ? Color("ButtonFaceColor") : Color.white
    }
    
    private var speakerAccessibilityLabel: String {
        viewModel.isSpeaking ? "Pausar pergunta" : "Ouvir pergunta"
    }
    
    private var speakerTint: Color {
        viewModel.isSpeaking ? Color("ButtonBorder") : Color("ButtonFaceColor")
    }
    
    init(questions: [String], feedbackEngine: FeedbackEngineProtocol, jobPosting: JobPosting, onFinish: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: InterviewSessionViewModel(
            questions: questions,
            feedbackEngine: feedbackEngine,
            jobPosting: jobPosting
        ))
        _feedbackEngine = State(initialValue: feedbackEngine)
        self.onFinish = onFinish
    }
    
    private var mascotSection: some View {
        VStack(spacing:5) {
            HStack(spacing:8) {
                MiaInterview(isSpeaking: viewModel.isSpeaking)
                    .fixedSize()                   // Garante o tamanho original de referência
                    .scaleEffect(0.35)             // Reduz a imagem e todas as posições em 70%
                    .frame(width: 100, height: 160) // Ajusta a caixa de layout para a View pai
                    .clipped()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Mia está falando")
                    
                speakerButton
                    .padding(.top, 30)
                
            }
            .padding(.top, 5)
//            .padding()
            questionBubble
                .padding(.bottom, 15)
            MicCard(isTranscribing: viewModel.isTranscribing, time: viewModel.formattedTime, onTap: {
                Task { await viewModel.checkingReset() }
            })
            .padding(.bottom, 20)
            Spacer(minLength: 50)
        }
    }

    private var speakerButton: some View {
        Button {
            Task { await viewModel.speakQuestion() }
        } label: {
            Image(systemName: speakerImageName)
                .font(.title3)
                .frame(width: 20, height: 20)
                .bold()
                .foregroundStyle(speakerForegroundStyle)
                .padding(5)
        }
        //  .accessibilityHidden(true)
        .accessibilityLabel(speakerAccessibilityLabel)
        .accessibilityHint(Text("Ouvir a pergunta novamente"))
        .tint(speakerTint)
        .buttonBorderShape(.circle)
        .buttonStyle(.glassProminent)
        .padding(.bottom, 8)
    }

    private var questionBubble: some View {
        VStack(alignment: .center, spacing: 0) {
            UpTriangle()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color("VoxyBackground"))

            VStack(alignment: .leading) {
                Text(viewModel.currentQuestion)
                    .font(Font.custom("Nunito", size: 17).weight(.semibold))
                    .accessibilityHidden(true)
            }
            .padding()
            .background(Color("VoxyBackground"))
            .cornerRadius(24)
        }
    }

    private var sessionContent: some View {
        VStack(alignment: .center, spacing: 20) {
            // Bloco da Pergunta e Áudio
//            VStack(alignment: .center, spacing: 0) {
//                speakerButton
//                questionBubble
//            }
//            .padding(.top, 16)

//          Spacer(minLength: 10)

            // Card do Microfone
//            MicCard(isTranscribing: viewModel.isTranscribing, time: viewModel.formattedTime, onTap: {
//                Task { await viewModel.checkingReset() }
//            })
//            .padding(.bottom, 20)
//            Spacer(minLength: 50)
        }
        //    .padding(.horizontal, 24)
    }

    private var advanceButton: some View {
        Button(action: {
            Task { await viewModel.advance() }
        }, label: {
            Text(viewModel.lastQuestion ? "Finalizar" : "Próxima")
                .bold()
        })
        .frame(maxWidth: .infinity)
        .buttonStyle(BlueGameButton())
        .disabled(viewModel.canGoToNextQuestion)
        .controlSize(.regular)
        .padding(.horizontal, 24)
        //   .padding(.bottom, 16)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(Color("PrimaryBlue"))
                .ignoresSafeArea(edges: .all)
            VStack {
                ScrollView {
                    mascotSection
                    sessionContent
                }
                .scrollIndicators(.hidden)

            }
            .padding(.horizontal, 24)
            advanceButton
        }
        .navigationTitle("Pergunta \(viewModel.currentIndex + 1) de \(viewModel.questions.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .background(SwipeBackBlocker())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.advance() }
                } label: {
                    Text("Pular")
                }
            }
        }
        .alert("Reconhecimento de fala negado", isPresented: $viewModel.showSpeechDeniedAlert) {
            Button("Abrir ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Agora não", role: .cancel) {}
        } message: {
            Text("Precisamos analisar suas respostas com o reconhecimento de fala")
        }
        
        .alert("Microfone bloqueado", isPresented: $viewModel.showMicPermissionAlert) {
            Button("Abrir ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Agora não", role: .cancel) {}
        } message: {
            Text("Precisamos do microfone para escutar suas respostas da entrevista")
        }
        
        .navigationDestination(isPresented: $viewModel.goToFeedback) {
            FeedbackView(
                engine: feedbackEngine as? (FeedbackEngineProtocol & FinalFeedbackProtocol),
                question: viewModel.currentQuestion,
                feedbacks: viewModel.feedbacks,
                answers: viewModel.answers,
                job: viewModel.jobPosting,
                onClose: onFinish
            )
        }
        .alert("Deseja recomeçar?", isPresented: $viewModel.restartConfirmation) {
            Button("Recomeçar", role: .destructive) {
                Task {
                    viewModel.restartTranscript()
                    await viewModel.record()
                }
            }
            Button("Cancelar", role: .cancel) {}
        }
        .onChange(of: viewModel.currentIndex) {
            Task { await viewModel.speakQuestion() }
        }
        .onAppear {
            Task { await viewModel.speakQuestion() }
            viewModel.requestSpeechPermission()
        }
        
        .alert("Tem certeza?", isPresented: $showExitConfirmation) {
            Button("Cancelar", role: .cancel) {}
            
            Button("Sair", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Se voltar ao início, você perderá o progresso da sua entrevista.")
        }
    }
}

private struct SwipeBackBlocker: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        SwipeBackBlockerViewController()
    }
    
    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
    
    private final class SwipeBackBlockerViewController: UIViewController {
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            navigationController?
                .interactivePopGestureRecognizer?
                .isEnabled = false
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            navigationController?
                .interactivePopGestureRecognizer?
                .isEnabled = true
        }
    }
}

#Preview {
    let questions: [String] = ["Que dia é hoje?", "Que dia é amanha?", "Qual é o ano atual?"]
    let jobPosting = JobPosting(
        title: "iOS Developer",
        companyName: "Voxy",
        jobDescription: "Desenvolvimento de apps em Swift/SwiftUI."
    )
    InterviewSessionView(
        questions: questions,
        feedbackEngine: FoundationFeedbackEngine(),
        jobPosting: jobPosting
    )
}
