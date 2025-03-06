//
//  TextFieldView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 21/02/2025.
//

import SwiftUI

struct TextFieldView: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        TextField(placeholder, text: $text)
                    .foregroundColor(.primary)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                    )
                    .textInputAutocapitalization(.never)
    }
}

#Preview {
    TextFieldView(
        placeholder: "Email",
        text: .constant("")
    )
}
