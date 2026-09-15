//
//  FirstMia.swift
//  Voxy
//
//  Created by Voxy Team on 15/09/26.
//

import SwiftUI

struct FirstMia: View {
    
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
                
            
            Image("FirstMiaBody")
                .scaleEffect(1.5)
                .offset(x: 0, y: 0)
            
            Image("FirstMiaEyes")
                .scaleEffect(1.5)
                .scaleEffect(y: isBlinking ? 0.1 : 1, anchor: .center)

                .rotationEffect(.degrees(isWaving ? 0 : -4), anchor: .topLeading)
                .offset(x: 5, y: -40)
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
    FirstMia()
}
