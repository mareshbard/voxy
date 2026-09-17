//
//  MiaAnimation.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct MiaAnimation: View {
    
    @State private var isWaving = false
    @State private var isBlinking = false
    
    var body: some View {
        
        ZStack {
            
            Image("MiaTail")
                .offset(x: -100, y: 45)
            
            Image("MiaArm")
                .rotationEffect(.degrees(isWaving ? 5 : 10), anchor: .bottomLeading)
                .offset(x: 60, y: 32)
                .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: isWaving)
            Image("Mia")
            
            Image("MiaEyes")
                .scaleEffect(y: isBlinking ? 0.09 : 1, anchor: .center)
                .offset(x: 0, y: -40)
                .animation(.easeInOut(duration: 0.08), value: isBlinking)
                
            
            Image("MiaBag")
                .rotationEffect(.degrees(isWaving ? 0 : 40), anchor: .top)
                .offset(x: -60, y: 95)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isWaving)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mia feliz e acenando")
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
            try? await Task.sleep(for: .seconds(2))
            isBlinking = true
            try? await Task.sleep(for: .milliseconds(120))
            isBlinking = false
        }
    }
}

#Preview {
    MiaAnimation()
}
