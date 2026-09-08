import SwiftUI
import AVFoundation

struct InterviewSessionView: View {
    @State private var viewModel: InterviewSessionViewModel
    @State private var feedbackEngine: FeedbackEngineProtocol
    @State private var didRecordSession = false
    @Environment(\.dismiss) private var dismiss
    
    init(questions: [String], feedbackEngine: FeedbackEngineProtocol, jobPosting: JobPosting) {
        _viewModel = State(initialValue: InterviewSessionViewModel(
            questions: questions,
            feedbackEngine: feedbackEngine,
            jobPosting: jobPosting
        ))
        _feedbackEngine = State(initialValue: feedbackEngine)
    }
    
    var body: some View {
        ZStack {
            Color(Color.bg)
                .ignoresSafeArea(edges: .all)
            VStack {
                ScrollView {
                    VStack {
                        
                    }
                    .padding(40)
                    .background(Color(.systemGray6))
                    VStack(alignment: .center, spacing: 20) {
                        // Bloco da Pergunta e Áudio
                        VStack(alignment: .center, spacing: 0) {
                            Button(action: {
                                Task { await viewModel.speakQuestion() }
                            }, label: {
                                Image(systemName: viewModel.isSpeaking ? "stop.fill" : "speaker.wave.1.fill")
                                    .bold()
                                    .foregroundStyle(Color(.bg))
                            })
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.circle)
                            .tint(Color(.timerBg))
                            .padding(.bottom, 8)
                            
                            VStack(alignment: .center, spacing: 0) {
                                Triangle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color(.systemGray6))
                                
                                VStack(alignment: .leading) {
                                    Text(viewModel.currentQuestion)
                                        .font(Font.custom("Nunito", size: 17).weight(.semibold))
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(24)
                            }
                        }
                        .padding(.top, 16)
                        
                        Spacer(minLength: 20)
                        
                        // Card do Microfone
                        MicCard(isTranscribing: viewModel.isTranscribing, time: viewModel.formattedTime, onTap: {
                            Task { await viewModel.checkingReset() }
                        })
                        
                        Spacer(minLength: 40)
                    }
                    //    .padding(.horizontal, 24)
                }
                .scrollIndicators(.hidden)
                
                Button(action: {
                    Task { await viewModel.advance() }
                }, label: {
                    Text("Próxima pergunta!")
                        .bold()
                })
                .frame(maxWidth: .infinity)
                .buttonStyle(GameButton())
                .disabled(viewModel.canGoToNextQuestion)
                .controlSize(.regular)
            }
            .padding(.horizontal, 24)
            
        }
        .navigationTitle("Pergunta \(viewModel.currentIndex + 1) de \(viewModel.questions.count)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.advance() }
                } label: {
                    Text("Pular")
                }
            }
        }
        .alert("Microfone bloqueado", isPresented: $viewModel.showMicPermissionAlert) {
            Button("Abrir ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Agora não", role: .cancel) {}
        } message: {
            Text("Precisamos do microfone para analisar suas respostas")
        }
        
        .onChange(of: viewModel.goToFeedback) { _, goToFeedback in
            if goToFeedback && !didRecordSession {
                StreakManager.recordSession()
                didRecordSession = true
            }
        }
        
        .navigationDestination(isPresented: $viewModel.goToFeedback) {
          FeedbackView(
                    engine: feedbackEngine as? (FeedbackEngineProtocol & FinalFeedbackProtocol),
                    question: viewModel.currentQuestion,
                    feedbacks: viewModel.feedbacks,
                    job: viewModel.jobPosting,
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
        }
    }
}

#Preview {
    //    let questions: [String] = ["Que dia é hoje?", "Que dia é amanha?", "Qual é o ano atual?"]
    //    InterviewSessionView(questions: questions)
    //
}
