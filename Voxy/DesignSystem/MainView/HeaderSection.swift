//
//  HeaderSection.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI

struct HeaderSection: View {
    var body: some View {
        VStack {
            Spacer() // Empurra todo o HStack para a parte inferior
            
            HStack {
                Spacer()
                
                Image("MascotImage")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 90, height: 90)
                
                Image("BallonImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256)
                    .overlay(
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Olá, Fulano!")
                                .font(.custom("Satoshi-Black", size: 19)
                                .weight(.black))
                                .foregroundStyle(Color("PrimaryFontColor"))
                            
                            Text("Vamos treinar hoje?")
                                .font(.custom("Nunito", size: 14)
                                .weight(.bold))
                                .foregroundStyle(Color("SecondaryFontColor"))
                        }
                        .padding(.horizontal, 30),
                        alignment: .leading
                    )
            }
            .padding(.horizontal, 24)
        }
        .frame(width: .infinity)
        .background(Color("PrimaryBlue"))
    }
}

#Preview {
    HeaderSection()
}
