import Foundation
import NaturalLanguage
import CoreML

/// A class that uses CoreML to detect programming languages from code snippets
class ProgrammingLanguageDetector {
    
    // Singleton instance
    static let shared = ProgrammingLanguageDetector()
    
    // CoreML model for language detection
    private var languageClassifier: NLModel?
    
    // Mapping of common languages to their identifiers
    private let languageMapping: [String: String] = [
        "swift": "Swift",
        "java": "Java",
        "python": "Python",
        "javascript": "JavaScript",
        "typescript": "TypeScript", 
        "cpp": "C++",
        "c#": "C#",
        "kotlin": "Kotlin",
        "rust": "Rust",
        "php": "PHP",
        "go": "Go",
        "ruby": "Ruby",
        "objective-c": "Objective-C",
        "html": "HTML",
        "css": "CSS",
        "sql": "SQL",
        "bash": "Bash",
        "xml": "XML",
        "json": "JSON",
        "yaml": "YAML"
    ]
    
    private init() {
        // Try to load the model if it exists
        loadModel()
    }
    
    /// Loads the NLModel for language detection
    private func loadModel() {
        do {
            // First attempt to load a custom model if available
            if let modelURL = Bundle.main.url(forResource: "ProgrammingLanguageClassifier", withExtension: "mlmodel") {
                let customModel = try MLModel(contentsOf: modelURL)
                languageClassifier = try NLModel(mlModel: customModel)
            }
        } catch {
            print("Failed to load CoreML model: \(error.localizedDescription)")
        }
    }
    
    /// Detects the programming language from code
    /// - Parameter code: The code snippet to analyze
    /// - Returns: The detected language identifier or nil if detection failed
    func detectLanguage(from code: String) -> String? {
        // Step 1: Try using the CoreML model if available
        if let classifier = languageClassifier {
            if let prediction = try? classifier.predictedLabel(for: code) {
                return languageMapping[prediction.lowercased()] ?? prediction
            }
        }
        
        // Step 2: Fall back to pattern-based detection
        return detectLanguageUsingPatterns(from: code)
    }
    
    /// Fallback method that uses pattern matching to detect languages
    /// - Parameter code: The code snippet to analyze
    /// - Returns: The detected language identifier or nil if detection failed
    private func detectLanguageUsingPatterns(from code: String) -> String? {
        let code = code.lowercased()
        
        // Check for JavaScript/TypeScript with enhanced detection FIRST
        if isLikelyJavaScriptOrTypeScriptCode(code) {
            // Further distinguish between JavaScript and TypeScript
            if code.contains(": number") || code.contains(": string") || code.contains(": boolean") ||
               code.contains("interface ") || code.contains(": ") && code.contains("type ") || 
               code.contains("<") && code.contains(">") && !code.contains("react.") ||
               code.contains("implements ") || code.contains("readonly ") || 
               code.contains("as ") && code.contains("type") || 
               code.contains("@") && code.contains("decorator") {
                return "typescript"
            }
            return "javascript"
        }
        
        // Check for CSS with enhanced detection
        if isLikelyCSSCode(code) {
            return "css"
        }
        
        // Check for PHP with enhanced detection
        if isLikelyPHPCode(code) {
            return "php"
        }
        
        // Check for Go with enhanced detection
        if isLikelyGoCode(code) {
            return "go"
        }
        
        // Check for Ruby with enhanced detection
        if isLikelyRubyCode(code) {
            return "ruby"
        }
        
        // Check for C++ with enhanced detection
        if isLikelyCPlusPlusCode(code) {
            return "cpp"
        }
        
        // Check for Java with enhanced detection
        if isLikelyJavaCode(code) {
            return "java"
        }
        
        // Check for Python with enhanced detection
        if isLikelyPythonCode(code) {
            return "python"
        }
        
        // Check for SQL with enhanced detection
        if isLikelySQLCode(code) {
            return "sql"
        }
        
        // Swift
        if code.contains("import swift") || code.contains("class") && code.contains("func") && !code.contains("function") 
            || code.contains("@state") || code.contains("@binding") || code.contains("@published") 
            || code.contains("@observedobject") || code.contains("@stateobject") || code.contains("@environment") 
            || code.contains("struct") && code.contains(": view") || code.contains("swiftui") 
            || code.contains("@main") || code.contains("@objc") || code.contains("uikit") {
            return "swift"
        }
        
        // C#
        if code.contains("using System") || (code.contains("namespace") && code.contains("{"))
            || code.contains("public class") || code.contains("private class") 
            || code.contains("protected class") || code.contains("internal class") 
            || code.contains("async Task") || code.contains("await ") 
            || (code.contains("var ") && code.contains(";")) || code.contains("string[]") 
            || code.contains("List<") || code.contains("IEnumerable<") || code.contains(".NET") 
            || code.contains("[Serializable]") || code.contains("[HttpGet]") 
            || code.contains("[Route") || (code.contains("get;") && code.contains("set;")) {
            return "c#"
        }
        
        // Kotlin
        if (code.contains("package ") && code.contains("kotlin")) || code.contains("fun ") 
            || code.contains("val ") || (code.contains("var ") && !code.contains(";"))
            || code.contains("companion object") || code.contains("data class") 
            || code.contains("sealed class") || code.contains("object ") 
            || code.contains("suspend ") || code.contains("coroutine") 
            || code.contains("@Composable") || code.contains("LiveData<") 
            || code.contains("ViewModel()") || code.contains("AndroidManifest.xml") {
            return "kotlin"
        }
        
        // Bash
        if code.contains("#!/bin/bash") || code.contains("#!/bin/sh") || code.contains("echo ") 
            || code.contains("if [[ ") || code.contains("elif [[ ") || code.contains("for i in ") 
            || code.contains("while [[ ") || (code.contains("case ") && code.contains(" in"))
            || (code.contains("function ") && code.contains("()")) || code.contains("export ") 
            || code.contains("source ") || (code.contains("|") && code.contains("grep"))
            || (code.contains("$") && code.contains("{")) {
            return "bash"
        }
        
        // XML
        if code.contains("<?xml") || (code.contains("</") && code.contains(">"))
            || code.contains("<![CDATA[") || code.contains("xmlns:") 
            || (code.contains("encoding=") && code.contains("?>"))
            || code.contains("<root>") || code.contains("</root>") 
            || (code.contains("<") && code.contains("/>"))
            || code.contains("<!DOCTYPE") || code.contains("<?xml-stylesheet") {
            return "xml"
        }
        
        // JSON
        if (code.contains("{") && code.contains("}") && (code.contains("\"") || code.contains(":")))
            || (code.contains("[") && code.contains("]") && code.contains("\"") && code.contains(","))
            || code.contains("null") || code.contains("true") || code.contains("false") 
            || (code.contains("{") && code.contains(":") && !code.contains(";")) {
            return "json"
        }
        
        // YAML
        if code.contains("---") || code.contains("apiVersion:") || code.contains("kind:") 
            || code.contains("metadata:") || code.contains("spec:") || code.contains("status:") 
            || (code.contains(":") && code.contains("-")) || code.contains("|-") || code.contains(">-") 
            || code.contains("!include") || code.contains("&anchor") 
            || code.contains("*ref") || code.contains("<<:") {
            return "yaml"
        }
        
        // Rust
        if code.contains("fn ") || code.contains("pub ") || code.contains("impl ") 
            || code.contains("struct ") || code.contains("enum ") || code.contains("trait ") 
            || code.contains("let mut") || code.contains("match ") 
            || (code.contains("->") && code.contains("Result<"))
            || code.contains("unsafe") || code.contains("async ") 
            || code.contains("crate::") || code.contains("#[derive") 
            || code.contains("Vec<") || code.contains("Option<") {
            return "rust"
        }
        
        // Objective-C
        if code.contains("#import") || code.contains("@interface") 
            || code.contains("@implementation") || code.contains("@property") 
            || code.contains("@synthesize") || code.contains("@protocol") 
            || code.contains("-(void)") || code.contains("+(void)") 
            || code.contains("NSString *") || code.contains("UIViewController") 
            || code.contains("alloc] init") || code.contains("@selector") 
            || code.contains("@end") || code.contains("[super ") {
            return "objective-c"
        }
        
        // HTML
        if code.contains("<!doctype html>") || code.contains("<html>") 
            || code.contains("</html>") || code.contains("<head>") 
            || code.contains("<body>") || code.contains("<div") 
            || code.contains("<span") || code.contains("<script") 
            || code.contains("<style") || code.contains("<a href") {
            return "html"
        }
        
        // Default fallback
        return "plaintext"
    }
    
    /// Enhanced CSS detection method
    private func isLikelyCSSCode(_ code: String) -> Bool {
        // Common CSS properties and features
        let cssProperties = [
            "color", "background", "margin", "padding", "border", "font", "display", "position",
            "width", "height", "top", "right", "bottom", "left", "float", "clear", "z-index",
            "overflow", "text-align", "text-decoration", "font-size", "font-weight", "font-family",
            "line-height", "vertical-align", "white-space", "letter-spacing", "word-spacing",
            "text-transform", "text-shadow", "box-shadow", "border-radius", "opacity", "transform",
            "transition", "animation", "visibility", "cursor", "content", "justify-content",
            "align-items", "flex", "grid", "gap", "outline", "backdrop-filter", "filter",
            "max-width", "min-width", "max-height", "min-height", "object-fit", "list-style"
        ]
        
        // CSS-specific patterns
        let cssPatterns = [
            "\\{[^{}]*:[^{}]*;[^{}]*\\}",                   // CSS rule pattern with semicolons
            "\\@media\\s+[^{}]+\\{",                         // Media queries
            "\\@keyframes\\s+[a-zA-Z0-9_-]+\\s*\\{",         // Keyframe animations
            "\\@font-face\\s*\\{",                           // Font face declaration
            "\\@import\\s+url\\(['\"]?[^'\"]+['\"]?\\)",     // Import statement
            "#[a-zA-Z0-9_-]+\\s*\\{",                        // ID selector
            "\\.[a-zA-Z0-9_-]+\\s*\\{",                      // Class selector
            "[a-zA-Z0-9_-]+\\s*:\\s*[a-zA-Z0-9_#()/,. -]+;", // Property-value pair
            "[a-zA-Z0-9_-]+\\s*\\[[^\\]]+\\]\\s*\\{",        // Attribute selector
            ":[a-zA-Z-]+\\(",                                // Pseudo-function like :not()
            ":[a-zA-Z-]+\\s*\\{",                            // Pseudo-class selector
            "::[a-zA-Z-]+\\s*\\{",                           // Pseudo-element selector
            "--[a-zA-Z0-9_-]+\\s*:",                         // CSS variables
            "var\\(--[a-zA-Z0-9_-]+\\)",                     // CSS variable usage
            "\\@supports\\s+",                               // Feature queries
            "!important"                                      // Important declaration
        ]
        
        // CSS frameworks and libraries
        let cssFrameworks = [
            "bootstrap", "tailwind", "bulma", "materialize", "foundation", "semantic-ui",
            "skeleton", "pure.css", "animate.css", "sass", "scss", "less"
        ]
        
        // Check for CSS properties with word boundaries
        var propertyCount = 0
        for property in cssProperties {
            let pattern = "\\b\(property)\\s*:"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                propertyCount += 1
                
                // If we find enough CSS properties, it's likely CSS
                if propertyCount >= 3 {
                    return true
                }
            }
        }
        
        // Check for CSS-specific patterns
        for pattern in cssPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong CSS pattern, it's very likely CSS
                return true
            }
        }
        
        // Check for CSS frameworks and libraries
        for framework in cssFrameworks {
            if code.contains(framework) {
                propertyCount += 1
            }
        }
        
        // Check for basic CSS structure
        let hasBracesWithSemicolon = code.contains("{") && code.contains("}") && code.contains(";")
        let hasPropertyColons = code.contains(":") && !code.contains("function") && !code.contains("=>")
        let hasMediaQuery = code.contains("@media")
        let hasCommonCSSAtRules = code.contains("@import") || code.contains("@keyframes") || code.contains("@font-face")
        let hasSelectors = code.contains(".") && code.contains("{") || code.contains("#") && code.contains("{")
        let hasColorValues = code.contains("#") && (code.contains("fff") || code.contains("rgb") || code.contains("hsl"))
        
        // Count CSS-specific features
        let cssFeatureCount = [hasBracesWithSemicolon, hasPropertyColons, hasMediaQuery, hasCommonCSSAtRules, hasSelectors, hasColorValues]
            .filter { $0 }.count
        
        if cssFeatureCount >= 2 || (propertyCount >= 2 && hasBracesWithSemicolon) {
            return true
        }
        
        // Final check: CSS typically has many semicolons and braces
        if hasBracesWithSemicolon && hasPropertyColons && (code.filter { $0 == ";" }.count > 2) {
            return true
        }
        
        return false
    }
    
    /// Enhanced JavaScript/TypeScript detection method
    private func isLikelyJavaScriptOrTypeScriptCode(_ code: String) -> Bool {
        // Common JavaScript/TypeScript keywords and features
        let jsKeywords = [
            "const", "let", "var", "function", "return", "if", "else", "for", "while", "do",
            "switch", "case", "default", "break", "continue", "class", "this", "super", "new",
            "try", "catch", "finally", "throw", "typeof", "instanceof", "in", "of", "delete",
            "void", "await", "async", "yield", "import", "export", "from", "as", "default",
            "extends", "implements", "interface", "type", "namespace", "module", "declare",
            "undefined", "null", "true", "false", "NaN", "Infinity", "console", "document",
            "window", "global", "process", "require", "Promise", "Array", "Object", "String",
            "Number", "Boolean", "Map", "Set", "Symbol", "Proxy", "Reflect", "JSON"
        ]
        
        // JavaScript/TypeScript specific patterns
        let jsPatterns = [
            "function\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*\\(.*\\)\\s*\\{", // Function declaration
            "const\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*=", // Const declaration
            "let\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*=", // Let declaration
            "var\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*=", // Var declaration
            "class\\s+[A-Z][a-zA-Z0-9_$]*\\s*\\{", // Class declaration
            "class\\s+[A-Z][a-zA-Z0-9_$]*\\s+extends\\s+[A-Z][a-zA-Z0-9_$]*\\s*\\{", // Class with inheritance
            "import\\s+\\{.*\\}\\s+from\\s+['\"].*['\"]", // ES6 import statement
            "export\\s+(default\\s+)?(function|class|const|let|var)", // ES6 export statement
            "\\(.*\\)\\s*=>\\s*\\{", // Arrow function
            "new\\s+[A-Z][a-zA-Z0-9_$]*\\(", // Object instantiation
            "this\\.[a-zA-Z_$][a-zA-Z0-9_$]*", // This reference
            "console\\.(log|error|warn|info|debug)\\(", // Console methods
            "document\\.(getElementById|querySelector|createElement)", // DOM manipulation
            "window\\.(addEventListener|setTimeout|setInterval)", // Window methods
            "async\\s+function\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*\\(", // Async function
            "await\\s+[a-zA-Z_$][a-zA-Z0-9_$]*", // Await expression
            "Promise\\.(all|race|resolve|reject)", // Promise methods
            "\\[[^\\]]*\\]\\.(map|filter|reduce|forEach|find|some|every)\\(", // Array methods
            "try\\s*\\{.*\\}\\s*catch\\s*\\(.*\\)\\s*\\{", // Try-catch block
            "if\\s*\\(.*\\)\\s*\\{.*\\}\\s*else\\s*\\{", // If-else statement
            "switch\\s*\\(.*\\)\\s*\\{.*case.*:.*break;", // Switch statement
            "for\\s*\\(let\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s+(of|in)\\s+", // For-of/in loop
            "module\\.exports\\s*=", // CommonJS exports
            "require\\(['\"].*['\"]\\)", // CommonJS require
            "<[A-Z][a-zA-Z0-9]*\\s*/?>", // JSX component
            "<[A-Z][a-zA-Z0-9]*\\s+.*>.*</[A-Z][a-zA-Z0-9]*>" // JSX component with content
        ]
        
        // TypeScript-specific patterns
        let tsPatterns = [
            "interface\\s+[A-Z][a-zA-Z0-9_$]*\\s*\\{", // Interface declaration
            "type\\s+[A-Z][a-zA-Z0-9_$]*\\s*=", // Type alias
            "[a-zA-Z_$][a-zA-Z0-9_$]*\\s*:\\s*(string|number|boolean|any|void|object|unknown)", // Type annotation
            "<[A-Z][a-zA-Z0-9_$]*>", // Generic type
            "implements\\s+[A-Z][a-zA-Z0-9_$]*", // Class implements interface
            "extends\\s+[A-Z][a-zA-Z0-9_$]*<.*>", // Generic inheritance
            "readonly\\s+[a-zA-Z_$][a-zA-Z0-9_$]*:", // Readonly property
            "\\?:\\s*(string|number|boolean|any|void)", // Optional parameter
            "as\\s+(const|[A-Z][a-zA-Z0-9_$]*)", // Type assertion
            "namespace\\s+[a-zA-Z_$][a-zA-Z0-9_$]*\\s*\\{", // Namespace
            "enum\\s+[A-Z][a-zA-Z0-9_$]*\\s*\\{", // Enum
            "@[a-zA-Z_$][a-zA-Z0-9_$]*" // Decorator
        ]
        
        // React-specific patterns
        let reactPatterns = [
            "import\\s+React", // React import
            "React\\.Component", // React class component
            "React\\.FC", // React functional component
            "useState\\(", // React hooks
            "useEffect\\(",
            "useContext\\(",
            "useRef\\(",
            "useMemo\\(",
            "useCallback\\(",
            "useReducer\\("
        ]
        
        // Node.js-specific patterns
        let nodePatterns = [
            "process\\.env", // Node.js process
            "fs\\.(readFile|writeFile|readdir)", // Node.js file system
            "path\\.(join|resolve)", // Node.js path
            "http\\.(createServer|request)", // Node.js http
            "express\\.(Router|static)", // Express.js
            "app\\.(get|post|put|delete)\\(" // Express.js routes
        ]
        
        // Check for JavaScript/TypeScript keywords with word boundaries
        var keywordCount = 0
        for keyword in jsKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough JS/TS keywords, it's likely JavaScript/TypeScript
                if keywordCount >= 3 {
                    return true
                }
            }
        }
        
        // Check for JavaScript-specific patterns
        for pattern in jsPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong JS pattern, it's very likely JavaScript
                return true
            }
        }
        
        // Check for TypeScript-specific patterns
        for pattern in tsPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong TS pattern, it's very likely TypeScript
                return true
            }
        }
        
        // Check for React patterns
        for pattern in reactPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                return true
            }
        }
        
        // Check for Node.js patterns
        for pattern in nodePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                return true
            }
        }
        
        // Check for combinations of JavaScript syntax elements
        let hasVariableDeclaration = code.contains("const ") || code.contains("let ") || code.contains("var ")
        let hasFunctionDeclaration = code.contains("function ") || code.contains("() =>") || code.contains("=> {")
        let hasImports = code.contains("import ") || code.contains("require(")
        let hasSemicolons = code.contains(";")
        let hasBraces = code.contains("{") && code.contains("}")
        
        // Count JavaScript-specific features
        let jsFeatureCount = [hasVariableDeclaration, hasFunctionDeclaration, hasImports, hasSemicolons, hasBraces]
            .filter { $0 }.count
        
        if jsFeatureCount >= 3 || (keywordCount >= 2 && jsFeatureCount >= 2) {
            return true
        }
        
        return false
    }
    
    /// Enhanced PHP detection method
    private func isLikelyPHPCode(_ code: String) -> Bool {
        // Common PHP keywords and features
        let phpKeywords = [
            "php", "function", "class", "interface", "trait", "namespace", "use", "extends",
            "implements", "public", "private", "protected", "static", "final", "abstract",
            "const", "var", "global", "require", "include", "require_once", "include_once",
            "echo", "print", "return", "if", "else", "elseif", "switch", "case", "default",
            "while", "do", "for", "foreach", "break", "continue", "try", "catch", "finally",
            "throw", "new", "clone", "instanceof", "array", "list", "true", "false", "null",
            "$this", "self", "parent", "__construct", "__destruct", "__call", "__get", "__set",
            "mysql", "mysqli", "pdo", "wordpress", "laravel", "symfony", "drupal", "composer"
        ]
        
        // PHP-specific patterns
        let phpPatterns = [
            "<?php", // PHP opening tag
            "\\?>", // PHP closing tag
            "\\$[a-zA-Z_][a-zA-Z0-9_]*\\s*=", // Variable assignment
            "function\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*\\(.*\\)\\s*\\{", // Function declaration
            "class\\s+[A-Z][a-zA-Z0-9_]*\\s*\\{", // Class declaration
            "class\\s+[A-Z][a-zA-Z0-9_]*\\s+extends\\s+[A-Z][a-zA-Z0-9_]*", // Class inheritance
            "interface\\s+[A-Z][a-zA-Z0-9_]*", // Interface declaration
            "trait\\s+[A-Z][a-zA-Z0-9_]*", // Trait declaration
            "namespace\\s+[a-zA-Z_\\\\][a-zA-Z0-9_\\\\]*;", // Namespace declaration
            "use\\s+[a-zA-Z_\\\\][a-zA-Z0-9_\\\\]*;", // Use statement
            "(public|private|protected)\\s+function\\s+", // Method declaration
            "(public|private|protected)\\s+(static\\s+)?\\$", // Property declaration
            "\\$[a-zA-Z_][a-zA-Z0-9_]*->", // Object property access
            "\\$this->", // $this reference
            "new\\s+[A-Z][a-zA-Z0-9_]*\\(", // Object instantiation
            "echo\\s+['\"]", // Echo string
            "require(_once)?\\s+['\"]", // Require statement
            "include(_once)?\\s+['\"]", // Include statement
            "foreach\\s*\\(\\s*\\$\\w+\\s+as\\s+\\$\\w+\\s*\\)", // Foreach loop
            "array\\s*\\(.*\\)", // Array declaration
            "\\[.*=>.*\\]", // Array with key
            "\\$_GET\\[", // Superglobals
            "\\$_POST\\[",
            "\\$_SESSION\\[",
            "\\$_COOKIE\\[",
            "\\$_SERVER\\[",
            "@[a-zA-Z_][a-zA-Z0-9_]*", // PHP annotations/docblocks
            "(mysql|mysqli|pdo)_", // Database functions
            "wp_", // WordPress functions
            "function\\s+add_action", // WordPress hooks
            "function\\s+add_filter"
        ]
        
        // Check for PHP keywords with word boundaries
        var keywordCount = 0
        for keyword in phpKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough PHP keywords, it's likely PHP
                if keywordCount >= 3 {
                    return true
                }
            }
        }
        
        // Check for PHP-specific opening tag (strongest indicator)
        if code.contains("<?php") || code.contains("<?=") {
            return true
        }
        
        // Check for PHP-specific patterns
        for pattern in phpPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong PHP pattern, it's very likely PHP
                return true
            }
        }
        
        // Check for combinations of PHP syntax elements
        let hasVariables = code.contains("$") 
        let hasFunctions = code.contains("function ")
        let hasEcho = code.contains("echo ") || code.contains("print ")
        let hasArrayAccess = code.contains("['") || code.contains("[\"") || code.contains("->")
        
        // Count PHP-specific features
        let phpFeatureCount = [hasVariables, hasFunctions, hasEcho, hasArrayAccess]
            .filter { $0 }.count
        
        if phpFeatureCount >= 2 || (keywordCount >= 2 && hasVariables) {
            return true
        }
        
        return false
    }
    
    /// Enhanced Go detection method
    private func isLikelyGoCode(_ code: String) -> Bool {
        // Common Go keywords and features
        let goKeywords = [
            "package", "import", "func", "return", "var", "const", "type", "struct",
            "interface", "map", "chan", "go", "select", "defer", "if", "else", "switch",
            "case", "default", "for", "range", "break", "continue", "fallthrough", "goto",
            "nil", "true", "false", "iota", "make", "new", "len", "cap", "append", "delete",
            "copy", "close", "complex", "real", "imag", "panic", "recover", "print", "println",
            "error", "string", "int", "int8", "int16", "int32", "int64", "uint", "uint8",
            "uint16", "uint32", "uint64", "uintptr", "byte", "rune", "float32", "float64",
            "complex64", "complex128", "bool", "err", "ctx", "context"
        ]
        
        // Go-specific patterns
        let goPatterns = [
            "package\\s+\\w+", // Package declaration
            "import\\s+\\(", // Import block
            "import\\s+\"", // Single import
            "func\\s+\\w+\\s*\\([^)]*\\)\\s*\\{", // Function declaration
            "func\\s+\\w+\\s*\\([^)]*\\)\\s*[a-zA-Z\\*]+\\s*\\{", // Function with return type
            "func\\s*\\([^)]*\\*?[A-Z]\\w*\\)\\s*\\w+\\s*\\(", // Method declaration
            "type\\s+\\w+\\s+struct\\s*\\{", // Struct definition
            "type\\s+\\w+\\s+interface\\s*\\{", // Interface definition
            "var\\s+\\w+\\s+[a-zA-Z]\\w*", // Variable declaration with type
            "const\\s+\\w+\\s+[a-zA-Z]\\w*", // Constant declaration with type
            "for\\s+\\w+\\s*:=\\s*range", // For range loop
            "if\\s+err\\s*:=", // Error checking pattern
            "if\\s+err\\s*!=\\s*nil", // Error checking
            "defer\\s+\\w+", // Defer statement
            "go\\s+\\w+\\(", // Goroutine
            "chan\\s+[a-zA-Z]\\w*", // Channel
            "make\\(\\s*map\\[", // Map creation
            "make\\(\\s*chan", // Channel creation
            "make\\(\\s*\\[]", // Slice creation
            "append\\(\\s*\\w+,", // Append function
            "\\w+\\s*:=\\s*\\w+", // Short variable declaration
            "fmt\\.Printf", // Standard library fmt
            "json\\.Marshal", // JSON encoding
            "http\\.ListenAndServe", // HTTP server
            "log\\.Printf", // Logging
            "os\\.Open", // File operations
        ]
        
        // Check for Go keywords with word boundaries
        var keywordCount = 0
        for keyword in goKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough Go keywords, it's likely Go
                if keywordCount >= 4 {
                    return true
                }
            }
        }
        
        // Check for Go-specific patterns
        for pattern in goPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong Go pattern, it's very likely Go
                return true
            }
        }
        
        // Check for combinations of Go syntax elements
        let hasPackage = code.contains("package ")
        let hasImport = code.contains("import ")
        let hasFunc = code.contains("func ")
        let hasGoStructure = code.contains("type ") && code.contains("struct ")
        let hasColonEqual = code.contains(":=")
        
        // Count Go-specific features
        let goFeatureCount = [hasPackage, hasImport, hasFunc, hasGoStructure, hasColonEqual]
            .filter { $0 }.count
        
        if goFeatureCount >= 2 || (keywordCount >= 3 && goFeatureCount >= 1) {
            return true
        }
        
        return false
    }
    
    /// Enhanced Ruby detection method
    private func isLikelyRubyCode(_ code: String) -> Bool {
        // Common Ruby keywords and features
        let rubyKeywords = [
            "def", "class", "module", "if", "elsif", "else", "unless", "case", "when",
            "while", "until", "for", "begin", "rescue", "ensure", "end", "do", "yield",
            "return", "next", "break", "redo", "retry", "super", "self", "nil", "true",
            "false", "and", "or", "not", "alias", "undef", "defined?", "loop", "in",
            "require", "include", "extend", "attr_accessor", "attr_reader", "attr_writer",
            "private", "protected", "public", "raise", "fail", "puts", "print", "p",
            "lambda", "proc", "new", "initialize", "to_s", "to_i", "to_a", "each"
        ]
        
        // Ruby-specific patterns
        let rubyPatterns = [
            "def\\s+[a-zA-Z_][a-zA-Z0-9_]*\\s*\\(?.*\\)?\\s*\\n",  // Method definition
            "class\\s+[A-Z][a-zA-Z0-9_]*\\s*(<\\s*[A-Z][a-zA-Z0-9_:]*)?", // Class definition
            "module\\s+[A-Z][a-zA-Z0-9_]*",                     // Module definition
            "attr_(accessor|reader|writer)\\s+:[a-zA-Z_][a-zA-Z0-9_]*", // Attribute declarations
            "require\\s+['\"].*['\"]",                          // Require statements
            "include\\s+[A-Z][a-zA-Z0-9_:]*",                   // Include module
            "extend\\s+[A-Z][a-zA-Z0-9_:]*",                    // Extend module
            "@[a-zA-Z_][a-zA-Z0-9_]*",                         // Instance variables
            "@@[a-zA-Z_][a-zA-Z0-9_]*",                        // Class variables
            "\\$[a-zA-Z_][a-zA-Z0-9_]*",                       // Global variables
            ":[a-zA-Z_][a-zA-Z0-9_]*",                         // Symbols
            "\\{\\s*\\|[^|]*\\|\\s*.*\\}",                      // Blocks with parameters
            "do\\s*\\|[^|]*\\|\\s*\\n",                         // do/end blocks with parameters
            "->(\\(.*\\))?\\s*\\{",                            // Lambda expressions
            "if.*\\bend\\b",                                    // if with end
            "unless.*\\bend\\b",                                // unless with end
            "['\"].*#\\{.*\\}.*['\"]",                         // String interpolation
            "\\%[qQrswWx]\\{.*\\}",                            // Alternative quoting
            "\\s+\\d+\\.\\.\\d+",                              // Range literals
            "\\w+\\.each\\s+do\\s*\\|",                        // Common Ruby iterators
            "\\w+\\.map\\s*\\{",
            "\\w+\\.select\\s*\\{",
            "Rails\\.\\w+",                                      // Rails framework
            "ActiveRecord::\\w+",                               // ActiveRecord ORM
            "RSpec\\.\\w+"                                      // RSpec testing
        ]
        
        // Check for Ruby keywords with word boundaries
        var keywordCount = 0
        for keyword in rubyKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough Ruby keywords, it's likely Ruby
                if keywordCount >= 3 {
                    return true
                }
            }
        }
        
        // Check for Ruby-specific patterns
        for pattern in rubyPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong Ruby pattern, it's very likely Ruby
                return true
            }
        }
        
        // Check for combinations of Ruby-specific syntax elements
        let hasDefEnd = code.contains("def ") && code.contains("end")
        let hasClassEnd = code.contains("class ") && code.contains("end")
        let hasDoEnd = code.contains("do") && code.contains("end")
        let hasRequire = code.contains("require '") || code.contains("require \"")
        let hasSymbols = code.contains(":")
        let hasBlockSyntax = code.contains(" do |") || code.contains("{ |")
        
        // Count Ruby-specific features
        let rubyFeatureCount = [hasDefEnd, hasClassEnd, hasDoEnd, hasRequire, hasSymbols, hasBlockSyntax]
            .filter { $0 }.count
        
        // If multiple Ruby features are present
        if rubyFeatureCount >= 2 || (keywordCount >= 2 && rubyFeatureCount >= 1) {
            return true
        }
        
        // Check for common Ruby gems and frameworks
        let rubyFrameworks = ["rails", "sinatra", "jekyll", "rake", "rspec", "cucumber", "capybara", 
                             "devise", "sidekiq", "puma", "bundler", "rack", "activerecord"]
        
        for framework in rubyFrameworks {
            if code.contains(framework) {
                return true
            }
        }
        
        return false
    }
    
    /// Enhanced C++ detection method
    private func isLikelyCPlusPlusCode(_ code: String) -> Bool {
        // Common C++ keywords and features
        let cppKeywords = [
            "include", "using", "namespace", "class", "struct", "template", "typename",
            "public", "private", "protected", "friend", "virtual", "override", "final",
            "const", "static", "volatile", "mutable", "auto", "extern", "inline",
            "operator", "new", "delete", "this", "std", "cout", "cin", "cerr",
            "vector", "map", "set", "list", "deque", "queue", "stack", "array",
            "shared_ptr", "unique_ptr", "weak_ptr", "nullptr", "enum", "union",
            "explicit", "noexcept", "constexpr", "decltype", "typeid", "typedef",
            "throw", "try", "catch", "if", "else", "switch", "case", "default",
            "for", "while", "do", "break", "continue", "return", "goto"
        ]
        
        // C++ specific patterns
        let cppPatterns = [
            "#include\\s+<[\\w\\.]+>",                         // Standard library include
            "#include\\s+\"[\\w\\.]+\"",                       // Custom header include
            "using\\s+namespace\\s+std;",                      // Using namespace statement
            "namespace\\s+[\\w_]+\\s*\\{",                     // Namespace definition
            "class\\s+[\\w_]+\\s*\\{",                         // Class definition
            "class\\s+[\\w_]+\\s*:\\s*(public|private|protected)\\s+[\\w_:]+", // Class with inheritance
            "template\\s*<\\s*\\w+\\s+\\w+\\s*>",              // Template declaration
            "std::(vector|map|string|set|list|deque|queue|stack|array)<", // STL containers
            "(public|private|protected)\\s*:",                 // Access specifiers
            "(virtual|override|final)\\s+\\w+\\s+\\w+\\s*\\(", // Virtual functions
            "operator\\s*[\\w\\+\\-\\*\\/\\[\\]]+\\s*\\(",     // Operator overloading
            "->\\s*\\w+",                                      // Pointer member access
            "\\w+\\s*<\\s*\\w+\\s*>\\s*\\w+",                 // Template instantiation
            "new\\s+\\w+",                                     // Dynamic allocation
            "delete\\s+(\\[\\])?\\s*\\w+",                     // Memory deallocation
            "\\w+::\\w+",                                      // Scope resolution
            "const_cast<",                                     // Type casting
            "static_cast<",
            "dynamic_cast<",
            "reinterpret_cast<",
            "std::cout\\s*<<",                                 // Stream operators
            "std::cin\\s*>>"
        ]
        
        // Check for C/C++ preprocessor directives
        let preprocessorPatterns = [
            "#define\\s+\\w+",
            "#ifdef\\s+\\w+",
            "#ifndef\\s+\\w+",
            "#endif",
            "#pragma\\s+\\w+",
            "#if\\s+defined",
            "#elif\\s+\\w+"
        ]
        
        // Check for C++ keywords with word boundaries
        var keywordCount = 0
        for keyword in cppKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough C++ keywords, it's likely C++
                if keywordCount >= 4 {
                    return true
                }
            }
        }
        
        // Check for C++ specific patterns
        for pattern in cppPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong C++ pattern, it's very likely C++
                return true
            }
        }
        
        // Check for preprocessor directives (strong indicator of C/C++)
        for pattern in preprocessorPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                // If we also find C++ keywords, it's likely C++
                if keywordCount >= 2 {
                    return true
                }
            }
        }
        
        // Check for header inclusion which is very specific to C/C++
        if code.contains("#include") {
            return true
        }
        
        // Check for common C++ patterns
        if (code.contains("std::") || code.contains("using namespace")) && 
           code.contains("{") && code.contains("}") && code.contains(";") {
            return true
        }
        
        // Check for class definition with access specifiers
        if (code.contains("class") || code.contains("struct")) && 
           (code.contains("public:") || code.contains("private:") || code.contains("protected:")) {
            return true
        }
        
        return false
    }
    
    /// Enhanced Java detection method
    private func isLikelyJavaCode(_ code: String) -> Bool {
        // Common Java keywords and features
        let javaKeywords = [
            "public", "private", "protected", "class", "interface", "enum", "abstract", 
            "extends", "implements", "static", "final", "void", "new", "this", "super",
            "import", "package", "try", "catch", "finally", "throw", "throws", "synchronized",
            "volatile", "transient", "native", "instanceof", "byte", "short", "int", "long",
            "float", "double", "boolean", "char", "String", "null", "true", "false",
            "if", "else", "switch", "case", "default", "for", "while", "do", "break", "continue",
            "return", "assert", "strictfp", "const", "goto"
        ]
        
        // Check for Java-specific patterns
        let javaPatterns = [
            "public\\s+class\\s+[A-Za-z0-9_]+\\s*\\{",                      // public class definition
            "private\\s+class\\s+[A-Za-z0-9_]+\\s*\\{",                     // private class definition
            "protected\\s+class\\s+[A-Za-z0-9_]+\\s*\\{",                   // protected class definition
            "class\\s+[A-Za-z0-9_]+\\s+extends\\s+[A-Za-z0-9_\\.]+\\s*\\{", // class with extends
            "class\\s+[A-Za-z0-9_]+\\s+implements\\s+[A-Za-z0-9_\\.,\\s]+\\s*\\{", // class with implements
            "public\\s+static\\s+void\\s+main\\s*\\(\\s*String\\s*\\[\\s*\\]", // main method
            "import\\s+java\\.",                                           // Java imports
            "@Override",                                                    // Common annotation
            "System\\.out\\.println",                                       // Common print statement
            "public\\s+[A-Za-z0-9_<>\\[\\]]+\\s+[a-zA-Z0-9_]+\\s*\\(",     // Public method
            "private\\s+[A-Za-z0-9_<>\\[\\]]+\\s+[a-zA-Z0-9_]+\\s*\\(",    // Private method
            "protected\\s+[A-Za-z0-9_<>\\[\\]]+\\s+[a-zA-Z0-9_]+\\s*\\(",  // Protected method
            "\\s+new\\s+[A-Za-z0-9_]+\\s*\\(",                             // Object instantiation
            "try\\s*\\{.*\\}\\s*catch\\s*\\([A-Za-z0-9_]+\\s+[a-z]+\\)\\s*\\{", // try-catch block
            "ArrayList<",                                                   // Common Java collections
            "HashMap<",
            "List<",
            "Map<",
            "Set<"
        ]
        
        // Check for keywords with word boundaries
        var keywordCount = 0
        for keyword in javaKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough Java keywords, it's likely Java
                if keywordCount >= 4 {
                    return true
                }
            }
        }
        
        // Check for Java-specific patterns
        for pattern in javaPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                // If we find any strong Java pattern, it's very likely Java
                return true
            }
        }
        
        // Check combination factors
        if keywordCount >= 3 &&
            (code.contains("{") && code.contains("}") && code.contains(";")) {
            return true
        }
        
        // Additional checks for Java style
        if (code.contains("public") || code.contains("private") || code.contains("protected")) &&
            code.contains("class") && code.contains("{") {
            return true
        }
        
        // Check for package declaration
        if let regex = try? NSRegularExpression(pattern: "package\\s+[a-z0-9_.]+;", options: []),
           let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
            return true
        }
        
        return false
    }
    
    /// Enhanced Python detection method
    private func isLikelyPythonCode(_ code: String) -> Bool {
        // Common Python keywords and features
        let pythonKeywords = [
            "def", "class", "import", "from", "if", "elif", "else", "for", "while",
            "try", "except", "finally", "with", "as", "pass", "break", "continue",
            "return", "yield", "lambda", "global", "nonlocal", "assert", "del",
            "raise", "in", "is", "not", "and", "or", "True", "False", "None",
            "self", "__init__", "__main__", "__name__", "__dict__", "__str__",
            "async", "await", "print", "list", "dict", "set", "tuple"
        ]
        
        // Check for Python indentation style with patterns ending in colon
        let indentationPatterns = [
            "def .+\\(.+\\):",
            "class .+:",
            "if .+:",
            "elif .+:",
            "else:",
            "for .+ in .+:",
            "while .+:",
            "try:",
            "except .+:",
            "except:",
            "finally:",
            "with .+ as .+:"
        ]
        
        // Check for Python pattern matches
        var keywordCount = 0
        var colonBlockFound = false
        var importStyleFound = false
        var pythonAnnotationFound = false
        
        // Check Python keywords with word boundaries
        for keyword in pythonKeywords {
            let pattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find enough Python keywords, it's likely Python
                if keywordCount >= 3 {
                    return true
                }
            }
        }
        
        // Look for Python block statements ending with colons
        for pattern in indentationPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                colonBlockFound = true
                break
            }
        }
        
        // Look for Python import style
        if let regex = try? NSRegularExpression(pattern: "from .+ import .+", options: []),
           let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
            importStyleFound = true
        } else if let regex = try? NSRegularExpression(pattern: "import [a-zA-Z0-9_\\.]+(, [a-zA-Z0-9_\\.]+)*", options: []),
                  let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
            importStyleFound = true
        }
        
        // Look for Python function/type annotations
        if let regex = try? NSRegularExpression(pattern: "def .+\\(.+\\) -> .+:", options: []),
           let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
            pythonAnnotationFound = true
        }
        
        // Look for Python decorators
        if let regex = try? NSRegularExpression(pattern: "@[a-zA-Z0-9_\\.]+", options: []),
           let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
            pythonAnnotationFound = true
        }
        
        // If we have multiple Python-specific patterns, it's likely Python
        let pythonSpecificCount = [colonBlockFound, importStyleFound, pythonAnnotationFound]
            .filter { $0 }.count
        if pythonSpecificCount > 0 || (keywordCount >= 2 && code.contains(":")) {
            return true
        }
        
        // Check for Python f-strings, list comprehensions and dictionary comprehensions
        let pythonSpecificPatterns = [
            "f['\"].*\\{.*\\}.*['\"]",  // f-strings
            "\\[.+ for .+ in .+\\]",    // list comprehensions
            "\\{.+:.+ for .+ in .+\\}"  // dictionary comprehensions
        ]
        
        for pattern in pythonSpecificPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                return true
            }
        }
        
        return false
    }
    
    /// Enhanced SQL detection method
    private func isLikelySQLCode(_ code: String) -> Bool {
        // Common SQL keywords (case insensitive)
        let sqlKeywords = [
            "select", "from", "where", "insert", "update", "delete", 
            "create", "alter", "drop", "table", "view", "index", 
            "join", "inner", "outer", "left", "right", "full", 
            "group by", "order by", "having", "union", "intersect", 
            "values", "into", "set", "on", "as", "distinct", "like",
            "between", "in", "exists", "all", "any", "and", "or", "not",
            "primary key", "foreign key", "constraint", "references",
            "count", "sum", "avg", "min", "max"
        ]
        
        // Check if there are multiple SQL keywords present
        var keywordCount = 0
        for keyword in sqlKeywords {
            // Check for word boundaries to avoid partial matches
            let keywordPattern = "\\b\(keyword)\\b"
            if let regex = try? NSRegularExpression(pattern: keywordPattern, options: .caseInsensitive),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                keywordCount += 1
                
                // If we find at least 3 distinct SQL keywords, it's very likely SQL
                if keywordCount >= 3 {
                    return true
                }
            }
        }
        
        // Check for common SQL patterns
        let sqlPatterns = [
            // SELECT statements
            "select .+ from",
            "select \\* from",
            // INSERT statements
            "insert into .+ values",
            "insert into .+ select",
            // UPDATE statements
            "update .+ set",
            // CREATE TABLE statements
            "create table .+\\(",
            // JOIN patterns
            "join .+ on",
            "where .+ =",
            "where .+ in",
            "where .+ like"
        ]
        
        for pattern in sqlPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let _ = regex.firstMatch(in: code, options: [], range: NSRange(location: 0, length: code.count)) {
                return true
            }
        }
        
        // Check SQL statement ratio - if a large portion of the code looks like SQL
        if keywordCount >= 2 && code.count < 200 {
            return true
        }
        
        return false
    }
    
    /// Gets a prettier name for a language identifier
    /// - Parameter languageId: The language identifier
    /// - Returns: A human-readable language name
    func getPrettyLanguageName(for languageId: String) -> String {
        return languageMapping[languageId.lowercased()] ?? languageId.capitalized
    }
} 
