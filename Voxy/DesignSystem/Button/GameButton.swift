//
//  GameButton.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI

struct BlueGameButton: ButtonStyle {
    var height: CGFloat = 60
    // Quando verdadeiro, remove a "moldura" 3D (camadas laterais/profundidade)
    // atrás da face, deixando apenas o botão sobre um fundo transparente.
    var transparentBackground: Bool = false
    
    var faceColor: Color = Color("ButtonFaceColor")
    var deepColor: Color = Color("ButtonBackgroundColor")
    var borderColor: Color = Color("ButtonBorder")
    
    var blueDisabledBg: Color = Color("blueDisabledBg")
    var blueDisabledBorder: Color = Color("BlueDisabledBorder")
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    
    @Environment(\.isEnabled) private var isEnabled
    private let borderWidth: CGFloat = 7
    private let lipHeight: CGFloat = 6
    
    func makeBody(configuration: Configuration) -> some View {
        
        ZStack {
            // cor lateral
            RoundedRectangle(cornerRadius: 16)
                .fill(transparentBackground ? .clear : (isEnabled ? borderColor : blueDisabledBorder))
                .shadow(radius: transparentBackground ? 0 : 1, x: 0, y: 2)
            // Cor principal
            RoundedRectangle(cornerRadius: 16)
                .fill(transparentBackground ? .clear : (isEnabled ? deepColor : blueDisabledBg))
                .shadow(radius: transparentBackground ? 0 : 1, x: 0, y: 2)
                .padding(borderWidth)
            // Face do botão
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? faceColor : blueDisabledBg)
                .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 4)
                .padding(borderWidth)
            
                .overlay(
                    configuration.label
                        .foregroundColor(isEnabled ? .white : Color("ButtonFontDisabled"))
                        .font(.custom("Satoshi-Bold", size: 24))
                )
                .offset(y: transparentBackground ? 0 : (configuration.isPressed ? 0 : -lipHeight * 1.6))
        }
        .frame(height: height)
        .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
        .onChange(of: configuration.isPressed) { _, isPressed in
            if isPressed {
                feedback.impactOccurred()
            }
        }
    }
}

#Preview {
    Button("Treinar!") {
    }
    .font(.custom("Satoshi-Bold", size: 20))
    .frame(maxWidth: .infinity)
    .buttonStyle(BlueGameButton())
    .disabled(true)
    .padding(.horizontal, 24)
}
