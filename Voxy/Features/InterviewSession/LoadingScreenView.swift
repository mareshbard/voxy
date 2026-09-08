//
//  LoadingScreenView.swift
//  Voxy
//
//  Created by Voxy Team on 04/09/26.
//

import SwiftUI

struct LoadingScreenView: View {
    var body: some View {
        
        VStack {
            Text("Criando a entrevista\nperfeita")
                .font(.custom("Satoshi-Black", size: 24))
                .tracking(1.1)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            ThreeDotsLoadingView()
            FoxyView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollContentBackground(.hidden)
        .background(Color("PrimaryBlue").ignoresSafeArea())
        
    }
}

#Preview {
    LoadingScreenView()
}
