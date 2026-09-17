//
//  OnBoardingPageIndicator.swift
//  Voxy
//
//  Created by Voxy Team on 15/09/26.
//

import SwiftUI

struct OnBoardingPageIndicator: View {
    @Binding var currentIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                let isSelected = index == currentIndex
                let size: CGFloat = isSelected ? 14 : 10
                
                Circle()
                    .fill(isSelected ? Color("OnBoardingSteps") : Color("StepsUnselected"))
                    .frame(width: size, height: size)

                    .padding(6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentIndex = index
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentIndex)
        .accessibilityElement()
        .accessibilityLabel("Etapa \(currentIndex + 1) de \(count)")
    }
}

#Preview {
    OnBoardingPageIndicator(currentIndex: .constant(0), count: 3)
        .padding()
        .background(Color("PrimaryBlue"))
}
