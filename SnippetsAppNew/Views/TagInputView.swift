//
//  TagInputView.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 22/02/2025.
//

import SwiftUI

struct TagInputView: View {
    @Binding var currentTag: String
    var onAddTag: () -> Void
       
    var body: some View {
        TextField(
            "Press enter to add a new tag",
            text: $currentTag,
            onCommit: {
                // First call the onAddTag function to add the tag
                onAddTag()
                
                // Then ensure the text field is cleared immediately
                DispatchQueue.main.async {
                    currentTag = ""
                }
            }
        )
        .opacity(0.5)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.3)
        )
    }
}

#Preview {
   
    TagInputView(currentTag: .constant("Angular"), onAddTag: {})
}
