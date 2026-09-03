import SwiftUI

struct MicCard: View {
    let isTranscribing: Bool
    let time: String
    let onTap: () -> Void
    
   var body: some View {
       ZStack {
           
           Color(.systemBackground)
           VStack(alignment: .center, spacing: 20) {
               
               VStack(alignment: .center) {
                   Text("Toque no microfone para responder")
                   Text("Você tem 2 minutos!")
               }
               .font(Font.custom("Nunito", size: 17)
            .weight(.semibold))
               
               Button(action: {
                   Task {
                       onTap()
                   }
               }, label: {
                   Image(systemName: isTranscribing ? "stop.fill" : "play.fill")
                       .foregroundColor(Color(.white))
                       .font(Font.system(size: 36))
                       .padding(12)
                   
               }
               )
               .buttonStyle(.borderedProminent)
               Text(time)
                   .font(Font.custom("Nunito", size: 17)
                .weight(.bold))
                   .padding(6)
                   .background(Color.timerBg)
                   .foregroundColor(.black)
                   .clipShape(RoundedRectangle(cornerRadius: 12))

                   .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.bg, lineWidth: 1.31)
                   )
           }
           .frame(maxWidth: .infinity)
           .padding()
           .cornerRadius(24)
           .background(Color.gray.opacity(0.1))
           
           
       }
       .cornerRadius(24)
    }
}
