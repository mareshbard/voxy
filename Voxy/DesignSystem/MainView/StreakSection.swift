//
//  StreakSection.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI

struct StreakSection: View {
    var body: some View {
        HStack(spacing: 0) {
            StreakItemView(title: "OFENSIVA", value: "3", unit: "dias", valueColor: Color("StreakColorGreen"))
                .frame(maxWidth: .infinity) // Divide o espaço igualmente (1/3)
            
            Rectangle()
                .fill(Color("DividerColor"))
                .frame(width: 1, height: .infinity) // Linha com altura fixa e elegante
            
            StreakItemView(title: "RECORDE", value: "15", unit: "dias", valueColor: Color("StreakColorYellow"))
                .frame(maxWidth: .infinity) // Divide o espaço igualmente (1/3)
            
            Rectangle()
                .fill(Color("DividerColor"))
                .frame(width: 1, height: .infinity)
            
            StreakItemView(title: "TOTAL", value: "15", unit: "sessões", valueColor: Color("StreakColorPink"))
                .frame(maxWidth: .infinity) // Divide o espaço igualmente (1/3)
        }
        .padding(.vertical, 10)
        .frame(width: .infinity, height: 100) // Expande para preencher a largura do pai
        .background(Color.white)    // Garante que o fundo não seja transparente
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("PrimaryBlue"), lineWidth: 2)
        )
    }
}

struct StreakItemView: View {
    let title: String
    let value: String
    let unit: String
    var valueColor: Color = Color("PrimaryFontColor")

    var body: some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.custom("Nunito", size: 12).weight(.bold))
                .tracking(1.1)
                .foregroundStyle(Color("PrimaryFontColor"))
            
            Text(value)
                .font(.custom("Nunito", size: 24).weight(.black))
                .foregroundStyle(valueColor)
            
            Text(unit)
                .font(.custom("Nunito", size: 14).weight(.bold))
                .foregroundStyle(Color("SecondaryFontColor"))
        }
    }
}

#Preview {
    StreakSection()
}
