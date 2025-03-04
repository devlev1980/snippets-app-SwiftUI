import SwiftUI

public struct ThemePickerView: View {
    @Binding var selectedTheme: String?
    let language: String
    let colorScheme: ColorScheme
    let code: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String = "All"
    
    public init(selectedTheme: Binding<String?>, language: String, colorScheme: ColorScheme, code: String) {
        self._selectedTheme = selectedTheme
        self.language = language
        self.colorScheme = colorScheme
        self.code = code
    }
    
    private var categories: [String] = ["All"] + Array(CodeEditorView.themeCategories.keys).sorted()
    
    private var filteredThemes: [String] {
        if selectedCategory == "All" {
            return CodeEditorView.recommendedThemes(for: language)
        } else if let themes = CodeEditorView.themeCategories[selectedCategory] {
            return themes
        }
        return CodeEditorView.availableThemes
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Category picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Theme preview
                let currentTheme = selectedTheme ?? (colorScheme == .dark ? "monokai" : "xcode")
                Text("Preview:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ThemePreviewView(
                    theme: currentTheme,
                    language: language,
                    code: code
                )
                .frame(height: 150)
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Themes grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 8)
                        ],
                        spacing: 8
                    ) {
                        ForEach(filteredThemes, id: \.self) { theme in
                            Button(action: {
                                selectedTheme = theme
                                CodeEditorView.ThemePreferences.saveTheme(theme, forLanguage: language)
                            }) {
                                Text(theme)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedTheme == theme ? Color.accentColor : Color.secondary.opacity(0.2))
                                    )
                                    .foregroundStyle(selectedTheme == theme ? .white : .primary)
                            }
                        }
                    }
                    .padding()
                }
                
                // Reset button
                Button("Reset to Default") {
                    selectedTheme = nil
                    CodeEditorView.ThemePreferences.clearTheme(forLanguage: language)
                    dismiss()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            }
            .navigationTitle("Select Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
