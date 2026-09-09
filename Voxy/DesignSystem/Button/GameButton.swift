//
//  GameButton.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI

struct GameButton: ButtonStyle {
    var height: CGFloat = 60
    
    var faceColor: Color = Color("ButtonFaceColor")
    var deepColor: Color = Color("ButtonBackgroundColor")
    var borderColor: Color = Color("ButtonBorder")
    var ButtonDisabledColor: Color = Color("ButtonDisabledColor")
    var blueDisabledForeground: Color = Color("ButtonDisabledForeground")
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    
    @Environment(\.isEnabled) private var isEnabled
    private let borderWidth: CGFloat = 7
    private let lipHeight: CGFloat = 6
    
    
    
    func makeBody(configuration: Configuration) -> some View {
        
        ZStack {
            // Borda externa
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? .white : borderColor)
                .shadow(radius: 1, x: 0, y: 2)
            // Cor principal
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? deepColor : ButtonDisabledColor)
                .shadow(radius: 1, x: 0, y: 2)
                .padding(borderWidth)
            // Face do botão
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? faceColor : ButtonDisabledColor)
                .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 4)
                .padding(borderWidth)
 
                .overlay(
                    configuration.label
                        .foregroundColor(isEnabled ? .white : borderColor)
                        .font(.custom("Satoshi-Bold", size: 24))
                )
                .offset(y: configuration.isPressed ? 0 : -lipHeight * 1.6)
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

struct BlueGameButton: ButtonStyle {
    var height: CGFloat = 60
    
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
                .fill(isEnabled ? .white : blueDisabledBorder)
                .shadow(radius: 1, x: 0, y: 2)
            // Cor principal
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? deepColor : blueDisabledBg)
                .shadow(radius: 1, x: 0, y: 2)
                .padding(borderWidth)
            // Face do botão
            RoundedRectangle(cornerRadius: 16)
                .fill(isEnabled ? faceColor : blueDisabledBg)
                .shadow(color: .white.opacity(0.3), radius: 0, x: 0, y: 4)
                .padding(borderWidth)
 
                .overlay(
                    configuration.label
                        .foregroundColor(isEnabled ? .white : blueDisabledBorder)
                        .font(.custom("Satoshi-Bold", size: 24))
                )
                .offset(y: configuration.isPressed ? 0 : -lipHeight * 1.6)
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
    .buttonStyle(GameButton())
    .padding(.horizontal, 24)
}
