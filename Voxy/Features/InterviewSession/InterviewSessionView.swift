import SwiftUI

struct InterviewSessionView: View {
    var body: some View {
        NavigationStack {
            Spacer()
            ScrollView {
                
                Button(action: {
                    
                }, label: {
                    Text("Próxima pergunta!")
                        .frame(maxWidth: .infinity)
                        
                })
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
               
              
            }
            .navigationTitle("Pergunta 1/5")
            .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
}

#Preview {
    InterviewSessionView()
}
