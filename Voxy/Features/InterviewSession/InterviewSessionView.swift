import SwiftUI
import AVFoundation

struct InterviewSessionView: View {
    @State private var viewModel: InterviewSessionViewModel
    @State private var feedbackEngine: FeedbackEngineProtocol
    @Environment(\.dismiss) private var dismiss

    init(questions: [String], feedbackEngine: FeedbackEngineProtocol) {
        _viewModel = State(initialValue: InterviewSessionViewModel(questions: questions, feedbackEngine: feedbackEngine))
        _feedbackEngine = State(initialValue: feedbackEngine)   
    }
    
    var body: some View {
        ZStack {
            Color(Color.bg)
                .ignoresSafeArea(edges: .all)
            VStack {
                Spacer()
                VStack {
                    ScrollView {
                        
                        VStack(alignment: .center) {
                            VStack {
                                
                            }
                            .padding(40)
                            .background(Color(.systemGray6))
                            Button(action: {
                                Task { await viewModel.speakQuestion()
                                    
                                }
                            }, label: {
                                Image(systemName: viewModel.isSpeaking ? "stop.fill" :"speaker.wave.1.fill")
                                    .bold()
                                    .foregroundStyle(Color(.bg))
                            })
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.circle)
                            .tint(Color(.timerBg))
                            VStack(alignment: .center, spacing: 0) {
                                
                                
                                Triangle()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color(.systemGray6))
                                
                                VStack(alignment: .center) {
                                    
                                    VStack(alignment: .leading) {
                                        Text(viewModel.currentQuestion)
                                            .font(
                                                Font.custom("Nunito", size: 17)
                                                    .weight(.semibold)
                                            )
                                    }
                                    
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(24)
                                
                            }
                        }
                        Spacer(minLength: 92)
                        MicCard(isTranscribing: viewModel.isTranscribing, time: viewModel.formattedTime, onTap: {
                            Task {
                                await viewModel.checkingReset()
                            }
                        })
                        Spacer()
                    }
                    .scrollIndicators(.hidden)
                    Button(action: {
                        Task {
                            await viewModel.advance()
                        }
                    }, label: {
                        Text("Próxima pergunta!")
                            .bold()
                            .frame(maxWidth: .infinity)
                        
                    })
                    .disabled(viewModel.canGoToNextQuestion)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                .navigationTitle("Pergunta \(viewModel.currentIndex + 1) de \(viewModel.questions.count)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                             await viewModel.advance()

                            }
                        } label: {
                            Text("Pular")
                        }
                        //  .disabled(viewModel.lastQuestion)
                    }
                    
                }
            }
            // binding manual, pois não foi possível usar uma variavel do viewModel diretamente no binding
            .alert("Microfone bloqueado", isPresented: $viewModel.showMicPermissionAlert) {
                Button("Abrir ajustes"){
                    if let url = URL(string: UIApplication.openSettingsURLString){
                        UIApplication.shared.open(url)
                    }
                }
                Button("Agora não", role: .cancel) {}
            } message: {
                Text("Precisamos do microfone para analisar suas respostas")
            }
            
            .navigationDestination(isPresented: $viewModel.goToFeedback, destination: {
                FeedbackView(question: viewModel.currentQuestion)
            })
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
                Task {
                    await viewModel.speakQuestion()
                }
            }
            .onAppear {
                Task {
                    await viewModel.speakQuestion()
                }
            }
            .padding()
        }
    }
}

#Preview {
//    let questions: [String] = ["Que dia é hoje?", "Que dia é amanha?", "Qual é o ano atual?"]
//    InterviewSessionView(questions: questions)
//    
}
