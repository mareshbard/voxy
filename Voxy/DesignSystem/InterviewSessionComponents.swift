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
                    Image(systemName: isTranscribing ? "stop.fill" : "mic.fill")
                        .foregroundColor(isTranscribing ? Color("ButtonFaceColor") : Color.white)
                        .font(Font.system(size: 36))
                        .frame(width: 44, height: 44)
                        .padding(12)
                    
                }
                )
                .accessibilityLabel(isTranscribing ? Text("Parar gravação") : Text("Iniciar gravação"))
                .buttonBorderShape(.circle)
                .tint(Color(isTranscribing ? Color("ButtonBorder") : Color("PrimaryBlue")))
                .buttonStyle(.glassProminent)
                
                
                Text(time)
                    .font(Font.custom("Nunito", size: 17)
                        .weight(.bold))
                    .padding(6)
                    .background(Color.clear)
                    .foregroundColor(Color(.label))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("PrimaryBlue"), lineWidth: 1.31)
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

struct UpTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        }
    }
}

struct SideTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY)) // Ponta
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()

        }
    }
}
