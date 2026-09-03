import SwiftUI

import SwiftUI

struct JobPostingCard: View {
    let title: String
    let companyName: String
    let lastSimulating: String
    let count: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.pink.opacity(0.3))
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom("Satoshi-Medium", size: 17))
                    .foregroundStyle(Color("PrimaryFontColor"))
                
                HStack(spacing: 4) {
                    Text(companyName)
                        .font(.custom("Nunito", size: 13).weight(.bold))
                        .foregroundStyle(Color("SecondaryFontColor"))
                    
                    Text(lastSimulating)
                        .font(.custom("Nunito", size: 13).weight(.regular))
                        .foregroundStyle(Color("SecondaryFontColor"))
                }
            }
            .padding(.vertical, 5)
            
            Spacer()
            
            VStack(alignment: .center, spacing: -2) {
                Text(count)
                    .font(.custom("Nunito", size: 22).weight(.bold))
                    .foregroundStyle(Color("PrimaryBlue"))
                
                Text(unit)
                    .font(.custom("Nunito", size: 12))
                    .foregroundStyle(Color("SecondaryFontColor"))
            }
        }
        .padding(12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("PrimaryBlue"))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("SecondaryBlue"))
                    .offset(x: -5, y: -5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
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
