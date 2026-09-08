//
//  HeaderSection.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI

struct HeaderSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AppStorage("username") private var username: String = ""

    private var isStacked: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 0))

        HStack {
            Spacer()

            layout {

                MiaAnimation()
                    .fixedSize()                  // Garante o tamanho original de referência
                    .scaleEffect(0.5)             // Reduz a imagem e todas as posições em 70%
                    .frame(width: 150, height: 150) // Ajusta a caixa de layout para a View pai
                    .clipped()                    // Corta as áreas 
                
//                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Olá, \(username)!")
                        .font(.custom("Satoshi-Black", size: 19, relativeTo: .title3).weight(.black))
                        .foregroundStyle(Color("BallonFontColor"))

                    Text("Vamos treinar hoje?")
                        .font(.custom("Nunito", size: 14, relativeTo: .subheadline).weight(.bold))
                        .foregroundStyle(Color("BallonSecondaryFontColor"))
                }
                .accessibilityElement(children: .combine)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 40)
                .padding(.trailing, 24)
                .padding(.vertical, 16)
                .frame(minWidth: 220, minHeight: 78, alignment: .leading)
                .background(
                    // Balão redimensionável: as bordas/rabinho ficam protegidas pelos capInsets
                    // enquanto o miolo estica para acompanhar o texto escalado pelo Dynamic Type.
                    Image("BallonImage")
                        .resizable(
                            capInsets: EdgeInsets(top: 30, leading: 30, bottom: 24, trailing: 24),
                            resizingMode: .stretch
                        )
                        .accessibilityHidden(true)
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .bottom)
        .background(
            // Sangra o fundo azul para fora dos listRowInsets (24pt) para não sobrar
            // borda branca da lista nas laterais, mesmo com o header crescendo.
            Color("PrimaryBlue")
                .padding(.horizontal, -24)
                .ignoresSafeArea(edges: .top)
        )
    }
}

#Preview {
    HeaderSection()
}

struct HeaderSectionHistory: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isStacked: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        let layout = isStacked
            ? AnyLayout(VStackLayout(spacing: 8))
            : AnyLayout(HStackLayout(spacing: 0))

        HStack {
            Spacer()

            layout {
                Image("MascotImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {

                    Text("Esse é seu histórico de vagas")
                    Text("Escolha uma para treinar!")
                }
                .accessibilityElement(children: .combine)
                .foregroundStyle(Color("BallonSecondaryFontColor"))
                .font(.custom("Nunito", size: 14, relativeTo: .subheadline).weight(.bold))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 40)
                .padding(.trailing, 24)
                .padding(.vertical, 16)
                .frame(minWidth: 256, minHeight: 78, alignment: .leading)
                .background(
                    // Balão redimensionável: as bordas/rabinho ficam protegidas pelos capInsets
                    // enquanto o miolo estica para acompanhar o texto escalado pelo Dynamic Type.
                    Image("BallonImage")
                        .resizable(
                            capInsets: EdgeInsets(top: 24, leading: 40, bottom: 24, trailing: 24),
                            resizingMode: .stretch
                        )
                        .accessibilityHidden(true)
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 234, alignment: .bottom)
        .background(
            // Sangra o fundo azul para fora dos listRowInsets (24pt) para não sobrar
            // borda branca da lista nas laterais, mesmo com o header crescendo.
            Color("PrimaryBlue")
                .padding(.horizontal, -24)
                .ignoresSafeArea(edges: .top)
        )
    }
}


