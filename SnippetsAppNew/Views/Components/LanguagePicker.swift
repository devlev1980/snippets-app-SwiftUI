//import SwiftUI
//
//struct LanguagePicker: View {
//    @Binding var selectedLanguage: String
//    
//    let languages = [
//        "plaintext",
//        "swift",
//        "javascript",
//        "python",
//        "java",
//        "cpp",
//        "csharp",
//        "ruby",
//        "php",
//        "go",
//        "rust",
//        "typescript",
//        "kotlin",
//        "sql",
//        "html",
//        "css",
//        "xml",
//        "json",
//        "yaml",
//        "markdown"
//    ]
//    
//    var body: some View {
//        Picker("Language", selection: $selectedLanguage) {
//            ForEach(languages, id: \.self) { language in
//                Text(language.capitalized)
//                    .tag(language)
//            }
//        }
//        .pickerStyle(.menu)
//    }
//} 
