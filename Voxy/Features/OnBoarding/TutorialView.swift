//
//  TutorialView.swift
//  Voxy
//
//  Created by Voxy Team on 15/09/26.
//

import SwiftUI

/// Tutorial de primeira abertura com navegação interativa (botões, swipes no mascote e toques no indicador).
struct TutorialView: View {
    let onFinished: () -> Void

    @State private var step = 0

    private let steps: [(title: String, message: String)] = [
        (
            "Adicione sua vaga",
            "Cole o texto ou envie uma foto da descrição da vaga que você quer treinar!"
        ),
        (
            "Treine com a Mia",
            "Receba perguntas personalizadas e treine por voz para a vaga que você inseriu!"
        ),
        (
            "Evolua a cada treino",
            "No feedback, descubra onde melhorar e treine novamente quantas vezes quiser!"
        )
    ]

    private var isLastStep: Bool { step == steps.count - 1 }

    var body: some View {
        VStack(spacing: 30) {
            Image("VoxyLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80)

            balloon
                .padding(.vertical, 8)

            mascot
                .frame(maxWidth: .infinity)
                .id(step)
                .transition(.opacity)
                .accessibilityLabel("Mia, nosso mascote, é uma raposa esperta vestida para uma entrevista de emprego.")
                .padding(.bottom, 20)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onEnded { value in
                            if value.translation.width < -50 {
                                if !isLastStep {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        step += 1
                                    }
                                }
                            } else if value.translation.width > 50 {
                                if step > 0 {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        step -= 1
                                    }
                                }
                            }
                        }
                )

            OnBoardingPageIndicator(currentIndex: $step, count: steps.count)

            Button(isLastStep ? "Finalizar" : "Próximo") {
                advance()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(BlueGameButton())

            Button("Pular") {
                onFinished()
            }
            .font(.custom("Satoshi", size: 24).weight(.bold))
            .tint(Color(.white))
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 15)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .safeAreaPadding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("PrimaryBlue"))
        .ignoresSafeArea()
    }

    private var balloon: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text(steps[step].title)
                    .font(.custom("Satoshi-Black", size: 24, relativeTo: .title3).weight(.black))
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(steps[step].message)
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

    @ViewBuilder
    private var mascot: some View {
        switch step {
        case 0:
            FirstMia()
        case 1:
            SecondMia(isSpeaking: true)
        default:
            ThirdMia()
        }
    }

    private func advance() {
        guard !isLastStep else {
            onFinished()
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            step += 1
        }
    }
}

struct DownTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    TutorialView(onFinished: {})
}
