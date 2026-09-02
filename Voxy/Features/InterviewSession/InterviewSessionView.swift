import SwiftUI
import AVFoundation

struct InterviewSessionView: View {
    @State private var viewModel = InterviewSessionViewModel(questions: ["Que dia é hoje?", "Que dia é amanha?", "Qual é o ano atual?"])
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        NavigationStack {
            Spacer()
            VStack {
                ScrollView {
                    
                    HStack(spacing: 8) {
                        VStack {
                            
                        }
                        .padding(40)
                        .background(Color(.systemGray6))
                        VStack {
                            
                            VStack(alignment: .leading) {
                                Text("MIA DIZ:")
                                    .font(.caption2.bold())
                                Text(viewModel.currentQuestion)
                            }
                            Button(action: {
                                Task { await viewModel.speakQuestion()
                                    
                                }
                            }, label: {
                                Image(systemName: viewModel.isSpeaking ? "stop.fill" :"play.fill")
                                Text("Ouvir pergunta")
                                    .bold()
                            })
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(24)
                        
                    }
                    Spacer(minLength: 92)
                    VStack(alignment: .center, spacing: 20) {
                        Text("---------------")
                            .foregroundColor(Color(.purpleFont))
                        
                        Text("Toque no microfone para responder")
                            .font(.callout)
                            .foregroundColor(Color(.purpleFont))
                        
                        Button(action: {
                            Task {
                                await viewModel.checkingReset()
                            }
                        }, label: {
                            Image(systemName: viewModel.isTranscribing ? "stop.fill" : "play.fill")
                                .foregroundColor(Color(.white))
                                .font(Font.system(size: 36))
                                .padding(12)
                            
                        }
                        )
                        .buttonStyle(.borderedProminent)
                        Text(viewModel.formattedTime)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(24)
                    
                    
                    Spacer()
                }
                Button(action: {
                    viewModel.nextQuestion()
                }, label: {
                    Text("Próxima pergunta!")
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                })
                .disabled(viewModel.canGoToNextQuestion)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            
            .navigationTitle("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Pular")
                    }
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

#Preview {
    let questions: [String] = ["Que dia é hoje?", "Que dia é amanha?", "Qual é o ano atual?"]
    InterviewSessionView()
    
}
