//
//  Highlighter.swift
//  SnippetsAppNew
//
//  Created by Yevgeny Levin on 01/03/2025.
//

import SwiftUI
import Highlightr

// Code formatter protocol
protocol CodeFormatter {
    func format(code: String, language: String?, useSpaces: Bool, tabWidth: Int) -> String
}

// Basic code formatter implementation
class BasicCodeFormatter: CodeFormatter {
    func format(code: String, language: String?, useSpaces: Bool, tabWidth: Int) -> String {
        guard let language = language?.lowercased() else { return formatGeneric(code: code, useSpaces: useSpaces, tabWidth: tabWidth) }
        
        switch language {
        case "swift":
            return formatSwift(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        case "json":
            return formatJSON(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        case "html", "xml":
            return formatXML(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        case "javascript", "typescript":
            return formatJS(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        case "css", "scss", "less":
            return formatCSS(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        default:
            return formatGeneric(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        }
    }
    
    // Helper to create indentation string based on preferences
    private func indentation(level: Int, useSpaces: Bool, tabWidth: Int) -> String {
        if useSpaces {
            return String(repeating: " ", count: level * tabWidth)
        } else {
            return String(repeating: "\t", count: level)
        }
    }
    
    private func formatSwift(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        var formattedCode = code
        
        // Basic indentation for braces
        formattedCode = formatGeneric(code: formattedCode, useSpaces: useSpaces, tabWidth: tabWidth)
        
        // Add space after keywords
        let swiftKeywords = ["if", "guard", "while", "for", "switch", "case", "func", "var", "let"]
        for keyword in swiftKeywords {
            formattedCode = formattedCode.replacingOccurrences(
                of: "\\b\(keyword)\\(", 
                with: "\(keyword) (",
                options: .regularExpression
            )
        }
        
        // Ensure space after commas
        formattedCode = formattedCode.replacingOccurrences(
            of: ",([^ \n])",
            with: ", $1",
            options: .regularExpression
        )
        
        // Ensure space after colons in dictionaries and type declarations
        formattedCode = formattedCode.replacingOccurrences(
            of: ":([^ \n])",
            with: ": $1",
            options: .regularExpression
        )
        
        // Add space after opening braces and before closing braces
        formattedCode = formattedCode.replacingOccurrences(
            of: "{([^ \n])",
            with: "{ $1",
            options: .regularExpression
        )
        formattedCode = formattedCode.replacingOccurrences(
            of: "([^ \n])}",
            with: "$1 }",
            options: .regularExpression
        )
        
        // Add space around operators
        let operators = ["+", "-", "*", "/", "=", "==", "!=", ">", "<", ">=", "<=", "&&", "||"]
        for op in operators {
            let escapedOp = op.map { char in
                if "+-*/.=><&|".contains(char) {
                    return "\\\(char)"
                }
                return String(char)
            }.joined()
            
            formattedCode = formattedCode.replacingOccurrences(
                of: "([^ \n])\(escapedOp)([^ \n])",
                with: "$1 \(op) $2",
                options: .regularExpression
            )
        }
        
        return formattedCode
    }
    
    private func formatJSON(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        // Simple JSON formatting
        guard let data = code.data(using: .utf8) else { return code }
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            if var prettyString = String(data: prettyData, encoding: .utf8) {
                // Replace default indentation with user preference
                if !useSpaces {
                    prettyString = prettyString.replacingOccurrences(
                        of: "    ",
                        with: "\t"
                    )
                } else if tabWidth != 4 {
                    prettyString = prettyString.replacingOccurrences(
                        of: "    ",
                        with: String(repeating: " ", count: tabWidth)
                    )
                }
                return prettyString
            }
        } catch {
            // If JSON is invalid, return original
            print("JSON formatting error: \(error)")
        }
        return code
    }
    
    private func formatXML(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        var formattedCode = code
        var indentLevel = 0
        var result = ""
        var isInTag = false
        var isInQuotes = false
        var isClosingTag = false
        
        for (index, char) in formattedCode.enumerated() {
            if char == "\"" {
                isInQuotes = !isInQuotes
            }
            
            if !isInQuotes {
                // Check for closing tag
                if index > 0 && formattedCode[formattedCode.index(formattedCode.startIndex, offsetBy: index - 1)] == "<" && char == "/" {
                    isClosingTag = true
                    indentLevel = max(0, indentLevel - 1)
                }
                
                if char == "<" && !isInTag {
                    isInTag = true
                    if !result.isEmpty && !result.hasSuffix("\n") {
                        result += "\n"
                    }
                    result += indentation(level: indentLevel, useSpaces: useSpaces, tabWidth: tabWidth)
                } else if char == ">" && isInTag {
                    isInTag = false
                    
                    // Check for self-closing tag
                    let isSelfClosing = index > 0 && formattedCode[formattedCode.index(formattedCode.startIndex, offsetBy: index - 1)] == "/"
                    
                    if !isClosingTag && !isSelfClosing {
                        indentLevel += 1
                    }
                    
                    isClosingTag = false
                }
            }
            
            result.append(char)
            
            if char == ">" && !isInTag && !isInQuotes {
                result += "\n"
            }
        }
        
        return result
    }
    
    private func formatJS(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        var formattedCode = formatGeneric(code: code, useSpaces: useSpaces, tabWidth: tabWidth)
        
        // Add space after keywords
        let jsKeywords = ["if", "for", "while", "switch", "function", "return", "var", "let", "const"]
        for keyword in jsKeywords {
            formattedCode = formattedCode.replacingOccurrences(
                of: "\\b\(keyword)\\(", 
                with: "\(keyword) (",
                options: .regularExpression
            )
        }
        
        // Ensure space after commas
        formattedCode = formattedCode.replacingOccurrences(
            of: ",([^ \n])",
            with: ", $1",
            options: .regularExpression
        )
        
        // Add space after opening braces and before closing braces
        formattedCode = formattedCode.replacingOccurrences(
            of: "{([^ \n])",
            with: "{ $1",
            options: .regularExpression
        )
        formattedCode = formattedCode.replacingOccurrences(
            of: "([^ \n])}",
            with: "$1 }",
            options: .regularExpression
        )
        
        // Add space around operators
        let operators = ["+", "-", "*", "/", "=", "==", "===", "!=", "!==", ">", "<", ">=", "<=", "&&", "||"]
        for op in operators {
            let escapedOp = op.map { char in
                if "+-*/.=><&|!".contains(char) {
                    return "\\\(char)"
                }
                return String(char)
            }.joined()
            
            formattedCode = formattedCode.replacingOccurrences(
                of: "([^ \n])\(escapedOp)([^ \n])",
                with: "$1 \(op) $2",
                options: .regularExpression
            )
        }
        
        return formattedCode
    }
    
    private func formatCSS(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        var formattedCode = code
        let indent = indentation(level: 1, useSpaces: useSpaces, tabWidth: tabWidth)
        
        // Add newline after closing brace
        formattedCode = formattedCode.replacingOccurrences(of: "}", with: "}\n")
        
        // Add newline and indent after opening brace
        formattedCode = formattedCode.replacingOccurrences(of: "{", with: " {\n\(indent)")
        
        // Add newline after semicolon
        formattedCode = formattedCode.replacingOccurrences(of: ";", with: ";\n\(indent)")
        
        // Add space after colon
        formattedCode = formattedCode.replacingOccurrences(
            of: ":([^ ])",
            with: ": $1",
            options: .regularExpression
        )
        
        return formattedCode
    }
    
    private func formatGeneric(code: String, useSpaces: Bool, tabWidth: Int) -> String {
        // Split the code into lines for better processing
        let lines = code.components(separatedBy: .newlines)
        var formattedLines: [String] = []
        var indentLevel = 0
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            if trimmedLine.isEmpty {
                formattedLines.append("")
                continue
            }
            
            // Check if line contains closing brace at the beginning
            if trimmedLine.hasPrefix("}") || trimmedLine.hasPrefix(")") || trimmedLine.hasPrefix("]") {
                indentLevel = max(0, indentLevel - 1)
            }
            
            // Add indentation
            let indentedLine = indentation(level: indentLevel, useSpaces: useSpaces, tabWidth: tabWidth) + trimmedLine
            
            // Add spaces around braces if they're not already there
            var processedLine = indentedLine
            
            // Add space after opening braces if there's not already a space or newline
            processedLine = processedLine.replacingOccurrences(
                of: "{([^ \n])",
                with: "{ $1",
                options: .regularExpression
            )
            
            // Add space before closing braces if there's not already a space
            processedLine = processedLine.replacingOccurrences(
                of: "([^ \n])}",
                with: "$1 }",
                options: .regularExpression
            )
            
            // Add space after opening parentheses if there's not already a space
            processedLine = processedLine.replacingOccurrences(
                of: "\\(([^ \n])",
                with: "( $1",
                options: .regularExpression
            )
            
            // Add space before closing parentheses if there's not already a space
            processedLine = processedLine.replacingOccurrences(
                of: "([^ \n])\\)",
                with: "$1 )",
                options: .regularExpression
            )
            
            // Add space after opening brackets if there's not already a space
            processedLine = processedLine.replacingOccurrences(
                of: "\\[([^ \n])",
                with: "[ $1",
                options: .regularExpression
            )
            
            // Add space before closing brackets if there's not already a space
            processedLine = processedLine.replacingOccurrences(
                of: "([^ \n])\\]",
                with: "$1 ]",
                options: .regularExpression
            )
            
            formattedLines.append(processedLine)
            
            // Check if line contains opening brace at the end
            if trimmedLine.hasSuffix("{") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[") {
                indentLevel += 1
            }
            
            // Check if line contains closing brace at the end (but not opening)
            if (trimmedLine.hasSuffix("}") || trimmedLine.hasSuffix(")") || trimmedLine.hasSuffix("]")) &&
               !(trimmedLine.hasSuffix("{") || trimmedLine.hasSuffix("(") || trimmedLine.hasSuffix("[")) {
                indentLevel = max(0, indentLevel - 1)
            }
        }
        
        return formattedLines.joined(separator: "\n")
    }
}

struct CodeEditorView: UIViewRepresentable {
    @Binding var code: String
    var language: String?
    var isDisabled: Bool = false
    var showLineNumbers: Bool = true
    var fontSize: CGFloat = 14
    var useSpaces: Bool = true
    var tabWidth: Int = 4
    var onFormat: (() -> Void)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let highlightr: Highlightr = {
        let highlightr = Highlightr()!
        return highlightr
    }()
    
    private let formatter = BasicCodeFormatter()
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.delegate = context.coordinator
        textView.isEditable = !isDisabled
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        
        // Set up text view appearance
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: showLineNumbers ? 40 : 8, bottom: 8, right: 8)
        
        // Add keyboard shortcut for formatting (Cmd+Shift+F)
        let formatAction = UIAction(title: "Format Code") { _ in
            context.coordinator.formatCode()
        }
        
//        if #available(iOS 15.0, *) {
//            textView.keyCommands = [
//                UIKeyCommand(title: "F", image: [.command, .shift], action: #selector(context.coordinator.handleKeyCommand(_:)), input: "Format Code")
//            ]
//        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Set theme based on color scheme
        let theme = colorScheme == .dark ? "monokai" : "xcode"
        highlightr.setTheme(to: theme)
        
        // Apply syntax highlighting
        if let highlightedCode = highlightr.highlight(code, as: language) {
            // Only update if the attributed text differs, to avoid cursor jump
            if uiView.attributedText.string != highlightedCode.string {
                uiView.attributedText = highlightedCode
            }
        } else {
            uiView.text = code
        }
        
        // Update editable state
        uiView.isEditable = !isDisabled
        
        // Add line numbers if enabled
        if showLineNumbers {
            context.coordinator.updateLineNumbers(for: uiView)
        } else {
            context.coordinator.lineNumberView?.removeFromSuperview()
            context.coordinator.lineNumberView = nil
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditorView
        var lineNumberView: LineNumberView?
        
        init(_ parent: CodeEditorView) {
            self.parent = parent
        }
        
        @objc func handleKeyCommand(_ sender: UIKeyCommand) {
            if sender.input == "F" && sender.modifierFlags.contains([.command, .shift]) {
                formatCode()
            }
        }
        
        func formatCode() {
            if !parent.isDisabled {
                let formatter = BasicCodeFormatter()
                parent.code = formatter.format(
                    code: parent.code,
                    language: parent.language,
                    useSpaces: parent.useSpaces,
                    tabWidth: parent.tabWidth
                )
                parent.onFormat?()
            }
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
            
            // Update line numbers if enabled
            if parent.showLineNumbers {
                updateLineNumbers(for: textView)
            }
            
            // Update the binding with the current text
            parent.code = textView.text
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Handle tab key press
            if text == "\t" && !parent.isDisabled {
                let currentText = textView.text as NSString
                let indentation = parent.useSpaces ? String(repeating: " ", count: parent.tabWidth) : "\t"
                
                // Insert the appropriate indentation
                textView.text = currentText.replacingCharacters(in: range, with: indentation)
                
                // Move cursor after the inserted tab
                let newPosition = range.location + indentation.count
                textView.selectedRange = NSRange(location: newPosition, length: 0)
                
                // Trigger text change to update highlighting
                textViewDidChange(textView)
                
                return false // We handled the tab ourselves
            }
            return true
        }
        
        func updateLineNumbers(for textView: UITextView) {
            if lineNumberView == nil {
                lineNumberView = LineNumberView(frame: CGRect(x: 0, y: 0, width: 40, height: textView.bounds.height))
                lineNumberView?.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
                textView.addSubview(lineNumberView!)
            }
            
            lineNumberView?.frame.size.height = textView.contentSize.height
            lineNumberView?.textView = textView
            lineNumberView?.setNeedsDisplay()
        }
    }
    
    // Format the code using the formatter
    func formatCode() -> String {
        return formatter.format(code: code, language: language, useSpaces: useSpaces, tabWidth: tabWidth)
    }
}

// Line number view for displaying line numbers
class LineNumberView: UIView {
    weak var textView: UITextView?
    
    override func draw(_ rect: CGRect) {
        guard let textView = textView, let context = UIGraphicsGetCurrentContext() else { return }
        
        // Clear background
        context.setFillColor(backgroundColor?.cgColor ?? UIColor.clear.cgColor)
        context.fill(rect)
        
        // Draw separator line
        context.setStrokeColor(UIColor.systemGray.withAlphaComponent(0.3).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: rect.width - 0.5, y: 0))
        context.addLine(to: CGPoint(x: rect.width - 0.5, y: rect.height))
        context.strokePath()
        
        // Get line count
        let text = textView.text ?? ""
        let lineCount = text.components(separatedBy: "\n").count
        
        // Font for line numbers
        let font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let textColor = UIColor.systemGray
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        let attribs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // Calculate line height
        let lineHeight = textView.font?.lineHeight ?? 14
        
        // Draw line numbers
        for i in 0..<lineCount {
            let lineNumber = "\(i + 1)"
            let yPos = CGFloat(i) * lineHeight + textView.textContainerInset.top
            
            let rect = CGRect(x: 0, y: yPos, width: self.bounds.width - 4, height: lineHeight)
            lineNumber.draw(in: rect, withAttributes: attribs)
        }
    }
}

// Helper extension to create a CodeView with SwiftUI styling
struct CodeView: View {
    @Binding var code: String
    var language: String?
    var isDisabled: Bool = false
    var showLineNumbers: Bool = true
    var fontSize: CGFloat = 14
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var useSpaces: Bool = true
    @State private var tabWidth: Int = 4
    @State private var showFormatOptions: Bool = false
    @State private var formatSuccessMessage: String? = nil
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                CodeEditorView(
                    code: $code,
                    language: language,
                    isDisabled: isDisabled,
                    showLineNumbers: showLineNumbers,
                    fontSize: fontSize,
                    useSpaces: useSpaces,
                    tabWidth: tabWidth,
                    onFormat: {
                        // Show success message
                        formatSuccessMessage = "Code formatted successfully!"
                        // Hide after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                formatSuccessMessage = nil
                            }
                        }
                    }
                )
                .background(colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                
                if !isDisabled {
                    HStack(spacing: 8) {
                        // Format options button
                        Button(action: {
                            showFormatOptions.toggle()
                        }) {
                            Image(systemName: "gear")
                                .foregroundColor(.indigo)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                                        .shadow(radius: 2)
                                )
                        }
                        .help("Formatting Options")
                        
                        // Format code button
                        Button(action: {
                            let formatter = BasicCodeFormatter()
                            code = formatter.format(code: code, language: language, useSpaces: useSpaces, tabWidth: tabWidth)
                            
                            // Show success message
                            formatSuccessMessage = "Code formatted successfully!"
                            // Hide after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    formatSuccessMessage = nil
                                }
                            }
                        }) {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.indigo)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                                        .shadow(radius: 2)
                                )
                        }
                        .help("Format Code")
                    }
                    .padding(8)
                }
            }
            
            // Format success message
            if let message = formatSuccessMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green.opacity(0.1))
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: formatSuccessMessage != nil)
                    .padding(.top, 4)
            }
            
            // Format options panel
            if showFormatOptions && !isDisabled {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Formatting Options")
                        .font(.headline)
                        .foregroundColor(.indigo)
                    
                    Divider()
                    
                    Toggle("Use spaces instead of tabs", isOn: $useSpaces)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("Tab width:")
                            .foregroundColor(.primary)
                        
                        Picker("", selection: $tabWidth) {
                            Text("2").tag(2)
                            Text("4").tag(4)
                            Text("8").tag(8)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 150)
                    }
                    
                    Text("Keyboard shortcut: ⌘⇧F")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    HStack {
                        Spacer()
                        Button("Close") {
                            showFormatOptions = false
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.indigo)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.black.opacity(0.9) : Color.white.opacity(0.9))
                        .shadow(radius: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                .transition(.opacity)
                .animation(.easeInOut, value: showFormatOptions)
            }
        }
    }
}
