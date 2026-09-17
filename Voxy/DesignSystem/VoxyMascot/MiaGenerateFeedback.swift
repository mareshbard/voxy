//
//  MiaGenerateFeedback.swift
//  Voxy
//
//  Created by Voxy Team on 09/09/26.
//

import SwiftUI

struct MiaGenerateFeedback: View {
    
    var isSpeaking: Bool = false
    
    @State private var isWaving = false
    @State private var isBlinking = false
    @State private var isMouthOpen = false
    
    var body: some View {
        
        
        
        ZStack {
            
            Image("MiaTail")
                .offset(x: -90, y: 95)
                .rotationEffect(.degrees(isWaving ? 0 : 5), anchor: .bottomTrailing)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
            
            Image("MiaFeedbackHead")
                .rotationEffect(.degrees(isWaving ? 0 : -2), anchor: .topLeading)
                .offset(x: 0, y: -80)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
            
            Image("MiaFeedbackBody")
                .offset(x: 0, y: 120)
            
            Image("MiaFeedbackEyes")
            // 1. Piscar: altera a escala no próprio eixo local da imagem.
            //    A animação de fechar/abrir é feita via withAnimation em blinkOnce().
                .scaleEffect(y: isBlinking ? 0.1 : 1, anchor: .center)
            
            // 2. Rotacionar e Deslocar: aplica o movimento e o posicionamento final
                .rotationEffect(.degrees(isWaving ? 0 : -4), anchor: .topLeading)
                .offset(x: 7, y: -35)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
            
        }
        .frame(maxWidth: .infinity)
        .task {
            await blinkEyes()
        }
        .onAppear {
            isWaving = true
        }
    }
    
    
    private func blinkEyes() async {
        while !Task.isCancelled {
            // Intervalo irregular entre piscadas: humanos não piscam em ritmo fixo.
            try? await Task.sleep(for: .seconds(.random(in: 2.5...5.5)))
            guard !Task.isCancelled else { break }
            
            await blinkOnce()
            
            // De vez em quando, uma piscada dupla para dar mais naturalidade.
            if Bool.random() {
                try? await Task.sleep(for: .milliseconds(150))
                guard !Task.isCancelled else { break }
                await blinkOnce()
            }
        }
    }
    
    private func blinkOnce() async {
        // Fecha o olho rápido...
        withAnimation(.easeIn(duration: 0.07)) { isBlinking = true }
        try? await Task.sleep(for: .milliseconds(90))
        // ...e abre um pouco mais devagar.
        withAnimation(.easeOut(duration: 0.12)) { isBlinking = false }
    }
    
}

#Preview {
    MiaGenerateFeedback()
}
