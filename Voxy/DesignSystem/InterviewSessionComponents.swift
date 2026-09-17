import SwiftUI



struct MicCard: View {
    let isTranscribing: Bool
    let time: String
    let onTap: () -> Void
    

    var body: some View {
        ZStack {

            Color(.systemBackground)
            VStack(alignment: .center, spacing: 15) {

                SpeakingWaveform(isActive: isTranscribing)
                    .accessibilityHidden(true)

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

struct SpeakingWaveform: View {
    var isActive: Bool
    var barCount: Int = 21
    var barWidth: CGFloat = 4
    var spacing: CGFloat = 5
    var maxHeight: CGFloat = 20
    var minHeight: CGFloat = 4

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !isActive)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    Capsule()
                        .fill(isActive ? Color("PrimaryBlue") : Color(.systemGray3))
                        .frame(width: barWidth, height: height(for: index, at: time))
                }
            }
            .frame(height: maxHeight)
            .animation(.easeOut(duration: 0.12), value: isActive)
        }
    }

    private func height(for index: Int, at time: TimeInterval) -> CGFloat {
        guard isActive else { return minHeight }
        // Combina duas ondas senoidais com defasagem por barra para um movimento
        // orgânico, sem parecer um padrão repetitivo perfeito.
        let phase = Double(index) * 0.55
        let wave = sin(time * 7 + phase) * 0.6 + sin(time * 3.3 + phase * 0.5) * 0.4
        let normalized = (wave + 1) / 2 // 0...1
        return minHeight + CGFloat(normalized) * (maxHeight - minHeight)
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
