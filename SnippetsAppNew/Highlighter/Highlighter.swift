//
//  Highlighter.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 01/03/2025.
//

import SwiftUI
import Highlightr

struct CodeEditorView: UIViewRepresentable {
    @Binding var code: String
     var language: String?
//    var language: String = "swift"
    private let highlightr: Highlightr = {
        let highlightr = Highlightr()!
        highlightr.setTheme(to: "atelier-cave-light") // choose a theme
        return highlightr
    }()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.delegate = context.coordinator
        textView.isEditable = true
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Apply syntax highlighting
        if let highlightedCode = highlightr.highlight(code, as: language) {
            // Only update if the attributed text differs, to avoid cursor jump.
            if uiView.attributedText.string != highlightedCode.string {
                uiView.attributedText = highlightedCode
            }
        } else {
            uiView.text = code
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditorView
        
        init(_ parent: CodeEditorView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Preserve the cursor position to avoid jumpy behavior
            let selectedRange = textView.selectedRange
            
            // Perform syntax highlighting immediately
            if let highlightedCode = parent.highlightr.highlight(textView.text, as: parent.language) {
                textView.attributedText = highlightedCode
                textView.selectedRange = selectedRange
            } else {
                textView.text = textView.text
            }
            
            // Update the binding with the current text
            parent.code = textView.text
        }
    }
}
