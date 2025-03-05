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
        let formattedCode = code
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
    var theme: String?
    var onFormat: (() -> Void)? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    
    // Create a new highlighter instance for each view to avoid theme conflicts
    private func createHighlighter() -> Highlightr {
        let highlighter = Highlightr()!
        let themeToUse = theme ?? (colorScheme == .dark ? "monokai" : "xcode")
        highlighter.setTheme(to: themeToUse)
        return highlighter
    }
    
    private let formatter = BasicCodeFormatter()
    
    // Available themes in Highlightr
    static let availableThemes = [
        "a11y-dark", "a11y-light", "agate", "an-old-hope", "androidstudio", 
        "arduino-light", "arta", "ascetic", "atom-one-dark", "atom-one-light",
        "codepen-embed", "color-brewer", "darcula", "dark", "default", "docco", 
        "dracula", "far", "foundation", "github", "github-gist", "googlecode", 
        "grayscale", "gruvbox-dark", "gruvbox-light", "hopscotch", "hybrid", 
        "idea", "ir-black", "kimbie.dark", "kimbie.light", "magula", "mono-blue", 
        "monokai", "monokai-sublime", "nord", "obsidian", "ocean", "paraiso-dark", 
        "paraiso-light", "pojoaque", "purebasic", "qtcreator_dark", "qtcreator_light", 
        "railscasts", "rainbow", "solarized-dark", "solarized-light", "sunburst", 
        "tomorrow", "tomorrow-night", "tomorrow-night-blue", "tomorrow-night-bright", 
        "tomorrow-night-eighties", "vs", "vs2015", "xcode", "xt256", "zenburn"
    ]
    
    // Theme categories for easier browsing
    static let themeCategories: [String: [String]] = [
        "Dark": [
            "a11y-dark", "agate", "an-old-hope", "androidstudio", "atom-one-dark", 
            "darcula", "dark", "dracula", "gruvbox-dark", "hopscotch", "hybrid", 
            "ir-black", "kimbie.dark", "monokai", "monokai-sublime", "nord", 
            "obsidian", "ocean", "paraiso-dark", "railscasts", "solarized-dark", 
            "tomorrow-night", "tomorrow-night-blue", "tomorrow-night-bright", 
            "tomorrow-night-eighties", "vs2015", "zenburn"
        ],
        "Light": [
            "a11y-light", "arduino-light", "ascetic", "atom-one-light", "color-brewer", 
            "default", "docco", "foundation", "github", "github-gist", "googlecode", 
            "idea", "kimbie.light", "magula", "paraiso-light", "qtcreator_light", 
            "solarized-light", "tomorrow", "vs", "xcode"
        ],
        "Colorful": [
            "arta", "codepen-embed", "far", "rainbow", "sunburst", "xt256"
        ],
        "Monochrome": [
            "grayscale", "mono-blue", "purebasic", "qtcreator_dark"
        ],
        "IDE Style": [
            "androidstudio", "darcula", "idea", "qtcreator_dark", "qtcreator_light", 
            "vs", "vs2015", "xcode"
        ]
    ]
    
    // Theme preferences manager
    struct ThemePreferences {
        private static let userDefaults = UserDefaults.standard
        private static let themePrefix = "code_theme_"
        private static let defaultDarkTheme = "monokai"
        private static let defaultLightTheme = "xcode"
        
        static func saveTheme(_ theme: String, forLanguage language: String) {
            userDefaults.set(theme, forKey: themeKey(for: language))
        }
        
        static func getTheme(forLanguage language: String, isDarkMode: Bool) -> String {
            let key = themeKey(for: language)
            return userDefaults.string(forKey: key) ?? 
                   (isDarkMode ? defaultDarkTheme : defaultLightTheme)
        }
        
        static func clearTheme(forLanguage language: String) {
            userDefaults.removeObject(forKey: themeKey(for: language))
        }
        
        static func clearAllThemes() {
            for key in userDefaults.dictionaryRepresentation().keys {
                if key.hasPrefix(themePrefix) {
                    userDefaults.removeObject(forKey: key)
                }
            }
        }
        
        private static func themeKey(for language: String) -> String {
            return "\(themePrefix)\(language.lowercased())"
        }
    }
    
    // Recommended themes for different languages
    static func recommendedThemes(for language: String?) -> [String] {
        guard let language = language?.lowercased() else {
            return ["xcode", "monokai", "github", "atom-one-dark", "solarized-dark"]
        }
        
        switch language {
        case "swift":
            return ["xcode", "atom-one-dark", "dracula", "monokai-sublime", "github"]
        case "javascript", "typescript":
            return ["atom-one-dark", "tomorrow-night", "monokai", "github", "solarized-dark"]
        case "html", "xml":
            return ["atom-one-light", "github", "xcode", "vs", "rainbow"]
        case "css", "scss", "less":
            return ["atom-one-dark", "tomorrow", "github", "xcode", "monokai"]
        case "python":
            return ["monokai", "dracula", "github", "solarized-dark", "xcode"]
        case "java":
            return ["idea", "github", "xcode", "monokai", "vs2015"]
        case "c", "cpp", "c++":
            return ["vs2015", "xcode", "github", "monokai", "atom-one-dark"]
        case "ruby":
            return ["github", "monokai", "dracula", "solarized-dark", "xcode"]
        case "go":
            return ["atom-one-dark", "github", "monokai", "xcode", "solarized-light"]
        case "rust":
            return ["github", "monokai", "dracula", "atom-one-dark", "xcode"]
        case "php":
            return ["atom-one-dark", "github", "monokai", "xcode", "solarized-dark"]
        case "json":
            return ["atom-one-dark", "github", "monokai", "xcode", "solarized-light"]
        case "markdown", "md":
            return ["github", "atom-one-light", "xcode", "solarized-light", "default"]
        default:
            return ["xcode", "monokai", "github", "atom-one-dark", "solarized-dark"]
        }
    }
    
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
        
        // Initialize the highlighter for this view
        context.coordinator.highlightr = createHighlighter()
        context.coordinator.currentTheme = theme ?? (colorScheme == .dark ? "monokai" : "xcode")
        
        // Add keyboard shortcut for formatting (Cmd+Shift+F)
        _ = UIAction(title: "Format Code") { _ in
            context.coordinator.formatCode()
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Set theme based on preference or color scheme
        let themeToUse = theme ?? (colorScheme == .dark ? "monokai" : "xcode")
        
        // Debug print to verify theme changes
        print("Applying theme: \(themeToUse) for language: \(language ?? "unknown")")
        
        // Force theme update by recreating the highlighter if theme changed
        if context.coordinator.currentTheme != themeToUse {
            context.coordinator.currentTheme = themeToUse
            context.coordinator.highlightr.setTheme(to: themeToUse)
            
            // Apply syntax highlighting with the new theme
            if let highlightedCode = context.coordinator.highlightr.highlight(code, as: language) {
                uiView.attributedText = highlightedCode
            } else {
                uiView.text = code
            }
        } else {
            // Apply syntax highlighting with existing theme
            if let highlightedCode = context.coordinator.highlightr.highlight(code, as: language) {
                // Only update if the attributed text differs, to avoid cursor jump
                if uiView.attributedText.string != highlightedCode.string {
                    uiView.attributedText = highlightedCode
                }
            } else {
                uiView.text = code
            }
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
        var currentTheme: String?
        var highlightr: Highlightr!
        
        init(_ parent: CodeEditorView) {
            self.parent = parent
            self.currentTheme = parent.theme ?? (parent.colorScheme == .dark ? "monokai" : "xcode")
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
            if let highlightedCode = highlightr.highlight(textView.text, as: parent.language) {
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
    var theme: String?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var useSpaces: Bool = true
    @State private var tabWidth: Int = 4
    @State private var showFormatOptions: Bool = false
    @State private var formatSuccessMessage: String? = nil
    @State private var selectedTheme: String? = nil
    @State private var showThemeOptions: Bool = false
    @State private var selectedThemeCategory: String = "All"
    @State private var isApplyingTheme: Bool = false
    @State private var themeAppliedMessage: String? = nil
    
    // Load saved theme when view appears
    private func loadSavedTheme() {
        if let language = language {
            let savedTheme = CodeEditorView.ThemePreferences.getTheme(
                forLanguage: language,
                isDarkMode: colorScheme == .dark
            )
            selectedTheme = savedTheme
        }
    }
    
    // Apply a theme with visual feedback
    private func applyTheme(_ theme: String) {
        isApplyingTheme = true
        
        // First set to nil to force a refresh
        selectedTheme = nil
        
        // Then apply the new theme after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTheme = theme
            
            if let language = language {
                CodeEditorView.ThemePreferences.saveTheme(theme, forLanguage: language)
            }
            
            // Show success message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isApplyingTheme = false
                themeAppliedMessage = "Theme '\(theme)' applied"
                
                // Hide after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        themeAppliedMessage = nil
                    }
                }
            }
        }
    }
    
    // Filtered themes based on selected category
    private var filteredThemes: [String] {
        if selectedThemeCategory == "All" {
            return CodeEditorView.availableThemes
        } else if let themes = CodeEditorView.themeCategories[selectedThemeCategory] {
            return themes
        } else {
            return CodeEditorView.availableThemes
        }
    }
    
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
                    theme: selectedTheme,
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
                .overlay(
                    Group {
                        if isApplyingTheme {
                            ZStack {
                                Color.black.opacity(0.4)
                                VStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Applying theme...")
                                        .foregroundColor(.white)
                                        .padding(.top, 8)
                                }
                            }
                        }
                    }
                )
                
                if !isDisabled {
                    HStack(spacing: 8) {
                        // Theme options button
                        Button(action: {
                            showThemeOptions.toggle()
                            showFormatOptions = false
                        }) {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.indigo)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.6) : Color.white.opacity(0.6))
                                        .shadow(radius: 2)
                                )
                        }
                        .help("Theme Options")
                        
                        // Format options button
                        Button(action: {
                            showFormatOptions.toggle()
                            showThemeOptions = false
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
            
            // Theme applied message
            if let message = themeAppliedMessage {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .transition(.opacity)
                    .animation(.easeInOut, value: themeAppliedMessage != nil)
                    .padding(.top, 4)
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
            
            // Theme options panel
            if showThemeOptions && !isDisabled {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme Options")
                        .font(.headline)
                        .foregroundColor(.indigo)
                    
                    Divider()
                    
                    Text("Recommended for \(language ?? "code"):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CodeEditorView.recommendedThemes(for: language), id: \.self) { theme in
                                Button(action: {
                                    applyTheme(theme)
                                }) {
                                    Text(theme)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedTheme == theme ? Color.indigo : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedTheme == theme ? .white : .primary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Theme categories
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Categories:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    selectedThemeCategory = "All"
                                }) {
                                    Text("All")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedThemeCategory == "All" ? Color.indigo : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedThemeCategory == "All" ? .white : .primary)
                                }
                                
                                ForEach(Array(CodeEditorView.themeCategories.keys).sorted(), id: \.self) { category in
                                    Button(action: {
                                        selectedThemeCategory = category
                                    }) {
                                        Text(category)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(selectedThemeCategory == category ? Color.indigo : Color.gray.opacity(0.2))
                                            )
                                            .foregroundColor(selectedThemeCategory == category ? .white : .primary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Text("All themes:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                            ForEach(filteredThemes, id: \.self) { theme in
                                Button(action: {
                                    applyTheme(theme)
                                }) {
                                    Text(theme)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedTheme == theme ? Color.indigo : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(selectedTheme == theme ? .white : .primary)
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    
                    // Theme preview
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Preview:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ThemePreviewView(
                            theme: selectedTheme ?? (colorScheme == .dark ? "monokai" : "xcode"),
                            language: language ?? "swift",
                            code: code
                        )
                        .frame(height: 150)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                    }
                    .padding(.top, 8)
                    
                    HStack {
                        Button("Reset to Default") {
                            selectedTheme = nil
                            if let language = language {
                                CodeEditorView.ThemePreferences.clearTheme(forLanguage: language)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        
                        Spacer()
                        
                        Button(action: {
                            // Force refresh the theme by toggling and re-applying
                            let currentTheme = selectedTheme
                            selectedTheme = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                selectedTheme = currentTheme
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.indigo)
                        }
                        .help("Refresh Theme")
                        .padding(.horizontal, 8)
                        
                        Button("Close") {
                            showThemeOptions = false
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
                .animation(.easeInOut, value: showThemeOptions)
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
        .onAppear {
            loadSavedTheme()
        }
        .onChange(of: colorScheme) { _ in
            loadSavedTheme()
        }
    }
}

// Theme preview component
struct ThemePreviewView: View {
    var theme: String
    var language: String
    var code: String
    
    var body: some View {
        VStack {
            CodeView(
                code: .constant(code),
                language: language,
                isDisabled: true,
                showLineNumbers: true,
                fontSize: 12,
                theme: theme
            )
            .frame(height: 150)
            
            Text(theme)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
    }
}

// A simplified view just for previewing code with themes
struct HighlightedCodeView: UIViewRepresentable {
    var code: String
    var language: String?
    var theme: String
    var fontSize: CGFloat = 12
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // Apply the theme and highlighting
        applyHighlighting(to: textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Apply the theme and highlighting when updated
        applyHighlighting(to: uiView)
    }
    
    private func applyHighlighting(to textView: UITextView) {
        // Create a fresh highlighter for each update to ensure theme is applied correctly
        let highlighter = Highlightr()!
        
        // Force theme to be set
        highlighter.setTheme(to: theme)
        
        // Apply highlighting
        if let highlightedCode = highlighter.highlight(code, as: language) {
            textView.attributedText = highlightedCode
        } else {
            textView.text = code
        }
    }
}
