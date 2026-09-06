//
//  FoxyView.swift
//  Voxy
//
//  Created by Voxy Team on 04/09/26.
//

import SwiftUI

struct FoxyView: View {

    var scale: CGFloat = 2
    @State private var isFloating = false
    @State private var isBlinking = false

    var body: some View {
        
        ZStack {

            Image("MacCat")
                .offset(x: 20 * scale / 2, y: 80 * scale / 2)
            
            Image("FoxyMascot")
                .offset(x: -5 * scale / 2, y: 10 * scale / 2)

            Image("FoxyEyes")
                .scaleEffect(y: isBlinking ? 0.02 : 1, anchor: .center)
                .offset(x: -5 * scale / 2, y: 5 * scale / 2)
                .animation(.easeInOut(duration: 0.05), value: isBlinking)

        }
        .scaleEffect(scale / 2)
        .offset(y: isFloating ? -10 : 0)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isFloating
        )
        .frame(maxWidth: .infinity)
        .onAppear {
            isFloating = true
        }
        .task {
            await blinkEyes()
        }
    }

    private func blinkEyes() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2))
            isBlinking = true
            try? await Task.sleep(for: .milliseconds(120))
            isBlinking = false
        }
    }
}

#Preview {
    FoxyView()
}
