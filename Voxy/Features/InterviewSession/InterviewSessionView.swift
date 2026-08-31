import SwiftUI
import AVFoundation
struct InterviewSessionView: View {
    
    @State private var viewModel = InterviewSessionViewModel()
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
                                Text("Me conta sobre um projeto de design que você desenvolveu do zero. Como foi o seu processo?")
                            }
                            Button(action: {
                                viewModel.speakQuestion()
                            }, label: {
                                Image(systemName: "play.fill")
                                
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
                            
                        }, label: {
                            Image(systemName: "mic.fill")
                                .foregroundColor(Color(.white))
                                .font(Font.system(size: 36))
                                .padding(12)
                            
                        }
                        )
                        .buttonStyle(.borderedProminent)
                        Text("00:00")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(24)
                    
                    
                    Spacer()
                }
                Button(action: {
                    
                }, label: {
                    Text("Próxima pergunta!")
                        .bold()
                        .frame(maxWidth: .infinity)
                    
                })
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
            }
            
            .navigationTitle("Pergunta 1/5")
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
        .onAppear {
            viewModel.speakQuestion()
        }
        .padding()
    }

}

#Preview {
    InterviewSessionView()
}
