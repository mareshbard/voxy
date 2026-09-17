//
//  HeaderSectionForm.swift
//  Voxy
//
//  Created by Voxy Team on 04/09/26.
//

import SwiftUI

struct HeaderSectionForm: View {
    var body: some View {
        VStack(spacing: 8) {
            // Mascote centralizado no topo.
            MiaForms()
                .fixedSize()                  // Garante o tamanho original de referência
                .scaleEffect(0.35)             // Reduz a imagem e todas as posições em 70%
                .frame(width: 150, height: 150) // Ajusta a caixa de layout para a View pai
                .clipped()
            
            VStack(alignment: .center, spacing: 0) {
                UpTriangle()
                    .accessibilityHidden(true)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color("VoxyBackground"))
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Vamos treinar!")
                        .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                    Text("Insira a descrição da vaga ou envie uma captura de tela!")
                        .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color("VoxyBackground"))
                .cornerRadius(24)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    HeaderSectionForm()
}
