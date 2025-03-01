import SwiftUI
import WebKit

struct HighlightedTextEditor: UIViewRepresentable {
    @Binding var text: String
    var language: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        // Load the HTML with Highlight.js
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/\(language).min.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 16px;
                    background-color: transparent;
                }
                pre {
                    margin: 0;
                    white-space: pre-wrap;
                }
                code {
                    font-family: monospace;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            <pre><code class="\(language)">\(text.replacingOccurrences(of: "<", with: "&lt;"))</code></pre>
            <script>hljs.highlightAll();</script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/\(language).min.js"></script>
            <style>
                body {
                    margin: 0;
                    padding: 16px;
                    background-color: transparent;
                }
                pre {
                    margin: 0;
                    white-space: pre-wrap;
                }
                code {
                    font-family: monospace;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            <pre><code class="\(language)">\(text.replacingOccurrences(of: "<", with: "&lt;"))</code></pre>
            <script>hljs.highlightAll();</script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HighlightedTextEditor
        
        init(_ parent: HighlightedTextEditor) {
            self.parent = parent
        }
    }
} 