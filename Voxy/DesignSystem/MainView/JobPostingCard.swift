import SwiftUI

import SwiftUI

struct JobPostingCard: View {
    let title: String
    let companyName: String
    let lastSimulating: String
    let count: String
    let unit: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Empilha empresa e data verticalmente quando a fonte atinge tamanhos de acessibilidade.
    private var isStacked: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: 48, height: 48)
            
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Satoshi-Medium", size: 17, relativeTo: .body))
                    .foregroundStyle(Color("PrimaryFontColor"))
                
                let subtitleLayout = isStacked
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
                    : AnyLayout(HStackLayout(spacing: 4))

                subtitleLayout {
                    Text(companyName)
                        .font(.custom("Nunito", size: 13, relativeTo: .footnote).weight(.bold))
                        .foregroundStyle(Color("SecondaryFontColor"))
                    
                    Text(lastSimulating)
                        .font(.custom("Nunito", size: 13, relativeTo: .footnote).weight(.regular))
                        .foregroundStyle(Color("SecondaryFontColor"))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 5)
            
            Spacer()
            
            VStack(alignment: .center, spacing: -2) {
                Text(count)
                    .font(.custom("Nunito", size: 22, relativeTo: .title2).weight(.bold))
                    .foregroundStyle(Color("PrimaryBlue"))
                
                Text(unit)
                    .font(.custom("Nunito", size: 12, relativeTo: .caption).weight(.regular))
                    .foregroundStyle(Color("SecondaryFontColor"))
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("PrimaryBlue"))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundJobCardColor"))
                    .offset(x: -5, y: -5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("PrimaryBlue"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


#Preview {
    JobPostingCard(
        title: "UX Designer Jr.",
        companyName: "iFood",
        lastSimulating: "Ontem, 10h45",
        count: "1",
        unit: "treinos"
    )
    .padding()
}

#Preview {
    JobPostingCard(
        title: "UX Designer Jr.",
        companyName: "iFood",
        lastSimulating: "Ontem, 10h45",
        count: "1",
        unit: "treinos"
    )
    .padding()
}
