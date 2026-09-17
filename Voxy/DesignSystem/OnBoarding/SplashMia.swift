//
//  SplashMia.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct SplashMia: View {
    var scale: CGFloat = 2
    @State private var isFloating = false
    @State private var isBlinking = false
    
    var body: some View {
        
        ZStack {
            Image("SplashMia")
            
            ZStack {
                
                Image("SplashEyes")
                    .scaleEffect(y: isBlinking ? 0.02 : 1, anchor: .center)
                    .offset(x: 20 * scale / 2, y: 70 * scale / 2)
                    .animation(.easeInOut(duration: 0.1), value: isBlinking)
                
            }
            .scaleEffect(scale / 2)
//            .offset(y: isFloating ? -10 : 0)
            .animation(
                .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                value: isFloating
            )
            .frame(maxWidth: .infinity)
            .onAppear {
                isFloating = true
            }
            .task {
                await blinkEyes()
            }
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
    SplashMia()
}
