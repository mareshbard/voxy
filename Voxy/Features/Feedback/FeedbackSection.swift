import SwiftUI

struct FeedbackSection: View {
    let title: String
    let items: [String]
    var highlighted: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("Nunito", size: 14))
                .foregroundColor(highlighted ? Color(.black) : Color(.secondaryLabel))
                .bold()

            ForEach(items, id: \.self) { item in
                HStack {
                    Circle().frame(width: 10, height: 10).foregroundColor(.bg)
                    Text(item)
                        .font(Font.custom("Nunito", size: 14))
                        .foregroundColor(Color(.gray))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(highlighted ? Color(.fbBg) : Color.clear)
        .cornerRadius(12)
        .foregroundStyle(highlighted ? Color(.black) : Color.primary)
    }
}
#Preview {
    ScrollView {
        FeedbackSection(title: "CLAREZA", items: ["Resposta clara", "Boa estrutura"])
        FeedbackSection(title: "VÍCIOS", items: ["tipo", "né", "então"], highlighted: true)
    }
}
