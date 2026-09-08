//
//  MiaForms.swift
//  Voxy
//
//  Created by Voxy Team on 08/09/26.
//

import SwiftUI

struct MiaForms: View {
    @State private var isWaving = false
    
    var body: some View {
        
        ZStack {
           
            Image("MiaTail")
                .offset(x: -100, y: 70)
            
            Image("MiaBody")
                .offset(x: 0, y: 120)
            
            Image("MiaHead")
                .rotationEffect(.degrees(isWaving ? -3 : 5), anchor: .center)
                .offset(x: 0, y: -70)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isWaving)
            
            
        }
        .frame(maxWidth: .infinity)
        
        .onAppear {
            isWaving = true
        }
    }
}

#Preview {
    MiaForms()
}
