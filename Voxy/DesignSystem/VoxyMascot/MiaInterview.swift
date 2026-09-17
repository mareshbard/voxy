//
//  MiaInterview.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct MiaInterview: View {

    var isSpeaking: Bool = false

    @State private var isWaving = false
    @State private var isBlinking = false
    @State private var isMouthOpen = false

    var body: some View {
        
        ZStack {
            
            Image("MiaTail")
                .offset(x: -70, y: 95)
                .rotationEffect(.degrees(isWaving ? 0 : 5), anchor: .bottomTrailing)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
            
            Image("MiaHeadInterview")
                .rotationEffect(.degrees(isWaving ? 0 : -2), anchor: .topLeading)
                .offset(x: 0, y: -75)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
            
            Image("MiaBodyInterview")
                .offset(x: 0, y: 120)
            
            Image("MiaEyesInterview")
                // 1. Piscar: altera a escala no próprio eixo local da imagem.
                //    A animação de fechar/abrir é feita via withAnimation em blinkOnce().
                .scaleEffect(y: isBlinking ? 0.1 : 1, anchor: .center)

                // 2. Rotacionar e Deslocar: aplica o movimento e o posicionamento final
                .rotationEffect(.degrees(isWaving ? 0 : -4), anchor: .topLeading)
                .offset(x: 15, y: -40)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)

            // Boca parada: aparece quando a Mia NÃO está falando.
            // Mesma ordem de modificadores dos olhos (rotação → offset → animação)
            // para acompanhar o movimento da cabeça.
            Image("MiaMouthInterview")
                .rotationEffect(.degrees(isWaving ? 0 : -4), anchor: .topLeading)
                .offset(x: 25, y: 15)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
                .opacity(isSpeaking ? 0 : 1)
                .animation(.easeInOut(duration: 0.15), value: isSpeaking)

            // Boca falando: aparece enquanto o áudio toca e anima a "mandíbula".
            Image("MiaSpeakingInterview")
                // 1. Falar: abre/fecha a mandíbula escalando a partir do topo.
                .scaleEffect(y: isMouthOpen ? 1 : 0.35, anchor: .top)
                // 2. Rotacionar e deslocar (igual aos olhos) para seguir a cabeça.
                .rotationEffect(.degrees(isWaving ? 0 : -4), anchor: .topLeading)
                .offset(x: 25, y: 18)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
                .opacity(isSpeaking ? 1 : 0)
                .animation(.easeInOut(duration: 0.15), value: isSpeaking)

        }
        .frame(maxWidth: .infinity)
        .task {
            await blinkEyes()
        }
        .task(id: isSpeaking) {
            await animateMouth()
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

    private func animateMouth() async {
        // Ao parar de falar (ou ao aparecer), garante a boca fechada.
        guard isSpeaking else {
            withAnimation(.easeOut(duration: 0.1)) { isMouthOpen = false }
            return
        }
        // Enquanto fala, alterna abrir/fechar em intervalos curtos e irregulares
        // para dar a impressão de sílabas.
        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 0.08)) { isMouthOpen.toggle() }
            try? await Task.sleep(for: .milliseconds(.random(in: 90...170)))
        }
    }
}
#Preview {
    MiaInterview(isSpeaking: true)
}
