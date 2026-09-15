//
//  SecondMia.swift
//  Voxy
//
//  Created by Voxy Team on 15/09/26.
//

import SwiftUI

struct SecondMia: View {
    var isSpeaking: Bool = false

    @State private var isWaving = false
    @State private var isBlinking = false
    @State private var isMouthOpen = false
    
    var body: some View {
        
        ZStack {
            Image("MiaTail")
                .scaleEffect(0.9)
                .offset(x: -70, y: 55)
                .rotationEffect(.degrees(isWaving ? 0 : 5), anchor: .bottomTrailing)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
                
            
            Image("SecondMiaBody")
                .scaleEffect(0.9)
                .offset(x: 0, y: 0)
            
            Image("SecondMiaEyes")
                .scaleEffect(1.6)
                .scaleEffect(y: isBlinking ? 0.1 : 1, anchor: .center)

                .offset(x: 5, y: -50)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isWaving)
            
            Image("MiaSpeakingInterview")
                .scaleEffect(0.8)
                // 1. Falar: abre/fecha a mandíbula escalando a partir do topo.
                .scaleEffect(y: isMouthOpen ? 1 : 0.35, anchor: .top)
 
                .offset(x: 8, y: 0)
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
            
            try? await Task.sleep(for: .seconds(.random(in: 2.5...5.5)))
            guard !Task.isCancelled else { break }

            await blinkOnce()

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
        
        guard isSpeaking else {
            withAnimation(.easeOut(duration: 0.1)) { isMouthOpen = false }
            return
        }
        
        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: 0.08)) { isMouthOpen.toggle() }
            try? await Task.sleep(for: .milliseconds(.random(in: 90...170)))
        }
    }
}


#Preview {
    SecondMia(isSpeaking: true)
}
