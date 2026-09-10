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
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Oi, eu sou a Mia")
                    .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                    .foregroundStyle(Color("BallonFontColor"))
                
                Text("e estou aqui para te ajudar a entrar no mundo corporativo! Como você se chama?")
                    .font(.custom("Nunito", size: 14, relativeTo: .subheadline).weight(.bold))
                    .foregroundStyle(Color("BallonSecondaryFontColor"))
                    .padding(.bottom, 10)
            }
            .accessibilityElement(children: .combine)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Image("BallonOnBoarding")
                    .resizable(
                        capInsets: EdgeInsets(top: 20, leading: 16, bottom: 10, trailing: 10),
                        resizingMode: .stretch
                    )
                    .accessibilityHidden(true)
            )
            
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
}

#Preview {
 OnBoardingView(viewModel: OnBoardingViewModel())
}
