//
//  QuestionCounterSelector.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI

struct QuestionCountSelector: View {
    @Binding var selectedValue: Int

    private let options = [6, 8, 10]
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        HStack(spacing: 12) {
            ForEach(options, id: \.self) { value in
                CardOption(
                    value: value,
                    isSelected: selectedValue == value
                ) {
                    guard selectedValue != value else { return }
                    impactGenerator.impactOccurred()
                    withAnimation(.easeOut(duration: 0.15)) {
                        selectedValue = value
                    }
                }
            }
        }
        .onAppear {
            impactGenerator.prepare()
        }
    }
}

private struct CardOption: View {
    let value: Int
    let isSelected: Bool
    let action: () -> Void

    private let selectedBackground = Color("PrimaryBlue")
    private let unselectedBorder = Color("PrimaryBlue")
    private let unselectedText = Color("DisabledFontColor")

    var body: some View {
        Button(action: action) {
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(isSelected ? .white : unselectedText)
                .frame(maxWidth: .infinity)
                .frame(height: 83)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? selectedBackground : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? Color.clear : unselectedBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var selected = 6
    return QuestionCountSelector(selectedValue: $selected)
        .padding()
}
