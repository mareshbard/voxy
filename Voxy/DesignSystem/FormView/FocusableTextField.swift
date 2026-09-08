//
//  FocusableTextField.swift
//  Voxy
//
//  Created by Voxy Team on 03/09/26.
//

import SwiftUI

struct FocusableTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.custom("Nunito-SemiBold", size: 14))
            .foregroundStyle(text.isEmpty ? Color("DisabledFontColor") : Color("PrimaryFontColor"))
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(isFocused ? Color("DarkerBlue") : Color("DropShadow"), lineWidth: 1)
            )
            .focused($isFocused)
    }
}
struct FocusableTextFieldDescription: View {
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.custom("Nunito-SemiBold", size: 14))
            .foregroundStyle(text.isEmpty ? Color("DisabledFontColor") : Color("PrimaryFontColor"))
            .lineLimit(3...10)
            .multilineTextAlignment(.leading)
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .stroke(isFocused ? Color("DarkerBlue") : Color("DropShadow"), lineWidth: 1)
                
            )
            .focused($isFocused)
        
    }
}

struct SectionLabel: View {
    
    let title: String
    let required: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                
                .font(.custom("Satoshi-Bold", size: 14))
                .tracking(1.1)
                .foregroundStyle(Color("PrimaryFontColor"))
                
            if required {
                Text("*")
                    .foregroundStyle(Color(("PrimaryFontColor")))
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth:.infinity, alignment: .leading)
    }
}
