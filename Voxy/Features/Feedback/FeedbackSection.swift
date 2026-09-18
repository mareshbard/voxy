import SwiftUI

/// Nível de desempenho de uma seção, exibido como etiqueta colorida.
enum FeedbackRating {
    case great   // verde
    case okay    // laranja
    case improve // vermelho

    var label: String {
        switch self {
        case .great: "Ótimo!"
        case .okay: "Legal!"
        case .improve: "Precisa melhorar!"
        }
    }

    var color: Color {
        switch self {
        case .great: Color(red: 0.20, green: 0.45, blue: 0.40)
        case .okay: Color(red: 0.95, green: 0.49, blue: 0.23)
        case .improve: Color(red: 0.79, green: 0.28, blue: 0.36)
        }
    }

    /// Emoji (asset) exibido no badge.
    var imageName: String {
        switch self {
        case .great: "Otimo"
        case .okay: "Legal"
        case .improve: "PrecisaMelhorar"
        }
    }

    /// Rating a partir da nota média de articulação (1...5) dada pelo feedback.
    static func forScore(_ score: Double) -> FeedbackRating {
        switch score {
        case ..<2.5: .improve
        case ..<4: .okay
        default: .great
        }
    }

    /// Seção de vícios: MENOS itens significa melhor desempenho.
    static func forVices(count: Int) -> FeedbackRating {
        switch count {
        case 0: .great
        case 1...2: .okay
        default: .improve
        }
    }
}

struct FeedbackSection: View {
    let title: String
    let items: [String]
    var highlighted: Bool = false
    // Quando presente, exibe a etiqueta colorida e mantém a seção sempre visível.
    var rating: FeedbackRating?
    // Mascote opcional exibido ao lado dos itens.
    var mascotImageName: String?
    var mascotPlacement: HorizontalEdge = .leading

    var body: some View {
        // Sem itens não há o que mostrar: escondemos a seção inteira (e o badge),
        // para não exibir um card vazio com etiqueta.
        if items.isEmpty {
            EmptyView()
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("Nunito", size: 16))
                .foregroundColor(highlighted ? Color(.fbText) : Color(.label))
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            if let rating {
                HStack(alignment: .center, spacing: 12) {
                    bullets
                    ratingBadge(rating)
                }
            } else if let mascotImageName {
                HStack(alignment: .center, spacing: 12) {
                    if mascotPlacement == .leading {
                        mascot(mascotImageName)
                    }
                    bullets
                    if mascotPlacement == .trailing {
                        mascot(mascotImageName)
                    }
                }
            } else {
                bullets
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(highlighted ? Color("BackgroundJobCardColor") : Color.clear)
        .cornerRadius(12)
        .foregroundStyle(highlighted ? Color(.grayText) : Color.primary)
    }

    private var bullets: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.bg)
                        .padding(.top, 5)
                    Text(item)
                        .font(Font.custom("Nunito", size: 16))
                        .foregroundColor(highlighted ? Color(.grayText) : Color(.gray))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func mascot(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 150)
            .accessibilityHidden(true)
    }

    private func ratingBadge(_ rating: FeedbackRating) -> some View {
        VStack(spacing: 10) {
            Image(rating.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
            Text(rating.label)
                .font(Font.custom("Nunito", size: 15).weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .frame(width: 108)
        .background(rating.color, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(rating.label)
    }
}

#Preview {
    ScrollView {
        FeedbackSection(title: "CLAREZA", items: ["Resposta clara", "Boa estrutura"], highlighted: true, rating: .great)
        FeedbackSection(title: "VÍCIOS", items: ["tipo", "né", "então"], highlighted: true, rating: .improve)
        FeedbackSection(title: "MELHORES MOMENTOS", items: ["Trouxe exemplos concretos"], mascotImageName: "MiaFeedbackLike", mascotPlacement: .leading)
        FeedbackSection(title: "ONDE MELHORAR", items: ["Detalhe o processo de validação"], mascotImageName: "MiaFeedbackClipboard", mascotPlacement: .trailing)
    }
    .padding()
}
