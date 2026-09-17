//
//  LoadingFeedbackView.swift
//  Voxy
//
//  Created by Voxy Team on 09/09/26.
//

import SwiftUI

struct LoadingFeedbackView: View {
    var body: some View {
        
        VStack {
            Spacer()
            Text("Analisando\nrespostas")
                .font(.custom("Satoshi-Black", size: 24))
                .tracking(1.1)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            ThreeDotsLoadingView()
                .padding(.bottom, 30)
//            Spacer()
            MiaGenerateFeedback()
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("Mia está olhando suas respostas!"))
                .fixedSize()                  // Garante o tamanho original de referência
                .scaleEffect(0.65)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .background(Color("PrimaryBlue").ignoresSafeArea())
        
    }
}


#Preview {
    LoadingFeedbackView()
}
