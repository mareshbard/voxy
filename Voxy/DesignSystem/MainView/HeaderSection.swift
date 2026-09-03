//
//  HeaderSection.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI

struct HeaderSection: View {
    var body: some View {
        HStack {
            Spacer()

            Image("MascotImage")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)

            Image("BallonImage")
                .resizable()
                .scaledToFit()
                .frame(width: 256, height: 78)
                .overlay(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Olá, Fulano!")
                            .font(.custom("Satoshi-Black", size: 19).weight(.black))
                            .foregroundStyle(Color("PrimaryFontColor"))

                        Text("Vamos treinar hoje?")
                            .font(.custom("Nunito", size: 14).weight(.bold))
                            .foregroundStyle(Color("SecondaryFontColor"))
                    }
                    .padding(.horizontal, 30)
                }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, minHeight: 234, alignment: .bottom)
        .background(Color("PrimaryBlue"))
    }
}

#Preview {
    HeaderSection()
}
