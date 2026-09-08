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

            // Balão branco full-width com rabinho apontando para cima (centro).
            VStack(alignment: .leading, spacing: 2) {
                Text("Vamos treinar!")
                    .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                    .foregroundStyle(Color("BallonFontColor"))

                Text("Insira a descrição da vaga ou envie uma captura de tela!")
                    .font(.custom("Nunito", size: 14, relativeTo: .subheadline).weight(.bold))
                    .foregroundStyle(Color("BallonSecondaryFontColor"))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 45)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                
                Image("BallonForm")
                    .resizable(
                        capInsets: EdgeInsets(top: 30, leading: 16, bottom: 16, trailing: 16),
                        resizingMode: .stretch
                    )
                    .padding(.horizontal, -24)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HeaderSectionForm()
}
