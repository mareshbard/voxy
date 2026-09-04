//
//  GameButton.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI

struct GameButton: ButtonStyle {
    
    var faceColor: Color = Color("ButtonFaceColor")
    var deepColor: Color = Color("ButtonBackgroundColor")
    var borderColor: Color = Color("ButtonBorder")
    
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    
    @Environment(\.isEnabled) private var isEnabled
    private let borderWidth: CGFloat = 7
    private let lipHeight: CGFloat = 6
    
    
    
    func makeBody(configuration: Configuration) -> some View {
        
        ZStack {
            // Borda externa
            RoundedRectangle(cornerRadius: 16)
                .fill(borderColor)
                .shadow(radius: 1, x: 0, y: 2)
            // Cor principal
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? deepColor : deepColor)
                .shadow(radius: 1, x: 0, y: 2)
                .padding(borderWidth)
            // Face do botão
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? faceColor : faceColor)
                .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 4)
                .padding(borderWidth)
 
                .overlay(
                    configuration.label
                        .foregroundColor(isEnabled ? .white : .white)
                        .font(.custom("Satoshi-Bold", size: 20))
                )
                .offset(y: configuration.isPressed ? 0 : -lipHeight * 1.6)
        }
        .frame(height: 60)
        .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
        .onChange(of: configuration.isPressed) { _, isPressed in
            if isPressed {
                feedback.impactOccurred()
            }
        }
    }
}

#Preview {
    Button("Treinar agora!") {
    }
    .font(.custom("Satoshi-Bold", size: 20))
    .frame(maxWidth: .infinity)
    .buttonStyle(GameButton())
    .padding(.horizontal, 24)
}

