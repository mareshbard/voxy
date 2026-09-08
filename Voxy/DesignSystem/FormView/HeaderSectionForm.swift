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
            Image("MascotImage")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)

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
                // Balão esticável: o topo (rabinho + canto arredondado) fica protegido
                // pelos capInsets enquanto o miolo estica para acompanhar o texto.
                // O asset tem 24pt de margem transparente embutida em cada lado, então
                // sangramos -24pt (cancelando o padding do formulário) para o branco do
                // balão alinhar exatamente com a largura dos textfields.
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
