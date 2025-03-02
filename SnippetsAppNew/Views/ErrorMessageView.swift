//
//  ErrorMessageView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 02/03/2025.
//

import SwiftUI

struct ErrorMessageView: View {
    let errorMessage: String
    var body: some View {
        HStack {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
        }
    }
}

#Preview {
    ErrorMessageView(errorMessage: "Something went wrong...")
}
