//
//  OnBoardingView.swift
//  Voxy
//
//  Created by Yohane Cavalcante on 28/08/26.
//

import SwiftUI

struct OnBoardingView: View {
    @Bindable var viewModel: OnBoardingViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            
            balloon

            MiaAnimation()
                .accessibilityLabel("Mia, nosso mascote, é uma raposa esperta vestida para uma entrevista de emprego.")
            
            FocusableTextField(
                placeholder: "Insira o seu nome...",
                text: $viewModel.nameInput
            )
            
            Button("Começar") {
                viewModel.register()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(BlueGameButton())
            .disabled(!viewModel.canRegister)
            
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("PrimaryBlue"))
        .ignoresSafeArea()
    }

    private var balloon: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Oi, eu sou a Mia")
                    .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("e estou aqui para te ajudar a entrar no mundo corporativo! Como você se chama?")
                    .font(.custom("Nunito", size: 16, relativeTo: .subheadline).weight(.bold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(Color("VoxyBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            DownTriangle()
                .accessibilityHidden(true)
                .frame(width: 22, height: 12)
                .foregroundStyle(Color("VoxyBackground"))
                .offset(y: -1)
        }
        .accessibilityElement(children: .combine)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

#Preview {
 OnBoardingView(viewModel: OnBoardingViewModel())
}
