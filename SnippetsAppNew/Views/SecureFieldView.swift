//
//  SecureFieldView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct SecureFieldView: View {
    let placeholder: String
    @Binding var password: String
    var body: some View {
        SecureField(placeholder, text: $password)
            .foregroundColor(.primary)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
            )
        
    }
}

#Preview {
    @Previewable @State var password = ""
    SecureFieldView(placeholder: "Password",password: $password)
}
