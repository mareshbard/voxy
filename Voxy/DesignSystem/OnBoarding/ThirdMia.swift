//
//  ThirdMia.swift
//  Voxy
//
//  Created by Voxy Team on 15/09/26.
//

import SwiftUI

struct ThirdMia: View {
    @State private var isWaving = false
    @State private var isBlinking = false
    @State private var isMouthOpen = false
    
    var body: some View {
        
        ZStack {
            Image("MiaTail")
                .scaleEffect(0.7)
                .offset(x: -80, y: 15)
                .rotationEffect(.degrees(isWaving ? 0 : 5), anchor: .bottomTrailing)
                .animation(.easeOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
                
            Image("ThirdMiaArm")
                .scaleEffect(1.4)
                .rotationEffect(.degrees(isWaving ? -2 : 25), anchor: .bottomLeading)
                .offset(x: 70, y: -45)
                
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
            
            Image("ThirdMiaBody")
                .scaleEffect(1.4)
                .offset(x: 0, y: 50)
            
            Image("ThirdMiaHead")
                .scaleEffect(1.4)
                .offset(x: -10, y: -110)
            
            


        }
        .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 250)
        .offset(y: 40)
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
    ThirdMia()
}
