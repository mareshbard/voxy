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
        
        HStack(spacing: 0) {
            Spacer()
            
            layout {
                
                MiaAnimation()
                    .fixedSize()                  // Garante o tamanho original de referência
                    .scaleEffect(0.5)             // Reduz a imagem e todas as posições em 70%
                    .frame(width: 150, height: 150) // Ajusta a caixa de layout para a View pai
                    .clipped()                    // Corta as áreas
                
                //                Spacer()
                if isStacked {
                    VStack(alignment: .center, spacing: 0) {
                        UpTriangle()
                        
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(.systemBackground))
                        
                        bubbleText
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(24)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack(alignment: .center, spacing: 0) {
                        SideTriangle()
                        
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(.systemBackground))
                        
                        bubbleText
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(24)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, isStacked ? 80 : 0)
        
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .bottom)
        .background(
            // Sangra o fundo azul para fora dos listRowInsets (24pt) para não sobrar
            // borda branca da lista nas laterais, mesmo com o header crescendo.
            Color("PrimaryBlue")
                .padding(.horizontal, -24)
                .ignoresSafeArea(edges: .top)
        )
    }
    var bubbleText: some View {
        VStack(alignment: .leading) {
            Text("Olá, \(username)!")
                .font(.custom("Satoshi-Black", size: 19, relativeTo: .title3).weight(.black))
            //.accessibilityHidden(true)
            Text("Vamos treinar hoje?")
                .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
                .foregroundStyle(Color.secondary)
        }
        .frame( minWidth: 160, maxWidth: .infinity, alignment: .leading)
    }
    
}

#Preview {
    HeaderSectionHistory()
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
        
        HStack(spacing: 0) {
            Spacer()
            
            layout {
                
                MiaAnimation()
                    .fixedSize()                  // Garante o tamanho original de referência
                    .scaleEffect(0.5)             // Reduz a imagem e todas as posições em 70%
                    .frame(width: 150, height: 150) // Ajusta a caixa de layout para a View pai
                    .clipped()                    // Corta as áreas
                
                //                Spacer()
                if isStacked {
                    VStack(alignment: .center, spacing: 0) {
                        UpTriangle()
                        
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(.systemBackground))
                        
                        bubbleText
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(24)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack(alignment: .center, spacing: 0) {
                        SideTriangle()
                        
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color(.systemBackground))
                        
                        bubbleText
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(24)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, isStacked ? 80 : 0)
        
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .bottom)
        .background(
            // Sangra o fundo azul para fora dos listRowInsets (24pt) para não sobrar
            // borda branca da lista nas laterais, mesmo com o header crescendo.
            Color("PrimaryBlue")
                .padding(.horizontal, -24)
                .ignoresSafeArea(edges: .top)
        )
    }
    var bubbleText: some View {
        VStack(alignment: .leading) {
            Text("Esse é seu histórico de vagas. Escolha uma para treinar!")
        }
        .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
        .foregroundStyle(Color.colorText)
        .frame( minWidth: 160, maxWidth: .infinity, alignment: .leading)
    }
}


