//
//  SplashView.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct SplashView: View {
    
    var duration: Duration = .seconds(0.5)
    
    var onFinished: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("VoxyLogo")
            
            SplashMia()
            
        }

        .padding(.bottom, -50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("PrimaryBlue"))
        .ignoresSafeArea()
        .task {
            try? await Task.sleep(for: duration)
            onFinished()
        }
    }
}


#Preview {
    SplashView(onFinished: {})
}
