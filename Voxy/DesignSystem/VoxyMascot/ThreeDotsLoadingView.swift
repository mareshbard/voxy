//
//  ThreeDotsLoadingView.swift
//  Voxy
//
//  Created by Voxy Team on 04/09/26.
//

import SwiftUI

struct ThreeDotsLoadingView: View {
    @State private var animate = false

    private let dotCount = 3
    private let minScale: CGFloat = 1
    private let maxScale: CGFloat = 1.6
    private let pulseDuration: Double = 0.5
    private let staggerDelay: Double = 0.2

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animate ? maxScale : minScale)
                    .animation(
                        .easeInOut(duration: pulseDuration)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * staggerDelay),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ThreeDotsLoadingView()
        .padding()
        .background(Color.black)
}
