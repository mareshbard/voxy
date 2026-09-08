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
                        .foregroundColor(Color(.bg))
                        .font(Font.system(size: 36))
                        .padding(12)
                    
                }
                )
                .buttonStyle(.glassProminent)
                .tint(.timerBg)
                
                .buttonBorderShape(.circle)
                
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

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
    }
}
