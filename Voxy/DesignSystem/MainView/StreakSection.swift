//
//  StreakSection.swift
//  Voxy
//
//  Created by Voxy Team on 02/09/26.
//

import SwiftUI

struct StreakSection: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Empilha as células verticalmente quando a fonte atinge tamanhos de acessibilidade.
    private var isStacked: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        let layout = isStacked ? AnyLayout(VStackLayout(spacing: 0)) : AnyLayout(HStackLayout(spacing: 0))

        layout {
            StreakItemView(title: "OFENSIVA", value: "3", unit: "dias", valueColor: Color("StreakColorGreen"))
                .frame(maxWidth: .infinity)

            divider

            StreakItemView(title: "RECORDE", value: "15", unit: "dias", valueColor: Color("StreakColorYellow"))
                .frame(maxWidth: .infinity)

            divider

            StreakItemView(title: "TOTAL", value: "15", unit: "sessões", valueColor: Color("StreakColorPink"))
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("PrimaryBlue"), lineWidth: 1)
        )
    }

    /// Divisor que acompanha a orientação do layout: vertical em linha, horizontal quando empilhado.
    private var divider: some View {
        Rectangle()
            .fill(Color("SecondaryBlue"))
            .frame(
                width: isStacked ? nil : 1,
                height: isStacked ? 1 : nil
            )
            .frame(maxWidth: isStacked ? .infinity : nil)
            .padding(isStacked ? .horizontal : [], 16)
            .padding(isStacked ? .vertical : [], 8)
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
