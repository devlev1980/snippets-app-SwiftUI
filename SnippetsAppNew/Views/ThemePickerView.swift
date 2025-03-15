import SwiftUI

public struct ThemePickerView: View {
    @Binding var selectedTheme: String?
    let language: String
    let colorScheme: ColorScheme
    let code: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String = "All"
    @State private var previewTheme: String? = nil
    @State private var isTransitioning: Bool = false
    
    public init(selectedTheme: Binding<String?>, language: String, colorScheme: ColorScheme, code: String) {
        self._selectedTheme = selectedTheme
        self.language = language
        self.colorScheme = colorScheme
        self.code = code
        self._previewTheme = State(initialValue: selectedTheme.wrappedValue)
    }
    
    // These are the well-tested themes that work reliably in each mode
    private let workingDarkThemes = [
        "atom-one-dark", "monokai", "dracula", "solarized-dark", 
        "tomorrow-night", "vs2015", "hybrid", "dark"
    ]
    
    private let workingLightThemes = [
        "xcode", "atom-one-light", "github", "solarized-light", 
        "vs", "idea", "github-gist"
    ]
    
    private var categories: [String] {
        if colorScheme == .dark {
            return ["All", "Dark", "IDE Style"]
        } else {
            return ["All", "Light", "IDE Style"]
        }
    }
    
    private var filteredThemes: [String] {
        // Base set of themes to filter from
        var baseThemes: [String] = []
        
        if selectedCategory == "All" {
            // Only show recommended themes that are known to work well
            let allRecommended = CodeEditorView.recommendedThemes(for: language)
            if colorScheme == .dark {
                baseThemes = allRecommended.filter { workingDarkThemes.contains($0) }
                // If no recommended themes work, show our default working dark themes
                if baseThemes.isEmpty {
                    baseThemes = workingDarkThemes
                }
            } else {
                baseThemes = allRecommended.filter { workingLightThemes.contains($0) }
                // If no recommended themes work, show our default working light themes
                if baseThemes.isEmpty {
                    baseThemes = workingLightThemes
                }
            }
        } else if selectedCategory == "Dark" {
            baseThemes = workingDarkThemes
        } else if selectedCategory == "Light" {
            baseThemes = workingLightThemes
        } else if selectedCategory == "IDE Style" {
            // Filter IDE style themes based on color scheme
            if colorScheme == .dark {
                baseThemes = ["vs2015", "darcula", "qtcreator_dark"]
            } else {
                baseThemes = ["xcode", "vs", "idea", "qtcreator_light"]
            }
        }
        
        return baseThemes
    }
    
    // Get the current theme to display in preview
    private var currentThemeForPreview: String {
        return previewTheme ?? selectedTheme ?? (colorScheme == .dark ? "monokai" : "xcode")
    }
    
    private func applyTheme(_ theme: String) {
        // Set the transition flag to prevent layout changes
        isTransitioning = true
        
        // Apply the theme
        previewTheme = theme
        selectedTheme = theme
        CodeEditorView.ThemePreferences.saveTheme(theme, forLanguage: language)
        
        // Reset the transition flag after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isTransitioning = false
        }
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
                
                // Theme preview section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    // Wrap in a ZStack to maintain consistent size during theme changes
                    ZStack {
                        ThemePreviewView(
                            theme: currentThemeForPreview,
                            language: language,
                            code: code
                        )
                    }
                    .frame(height: 250, alignment: .center)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    // Disable animations for size changes
                    .animation(.none, value: isTransitioning)
                    // Fix the layout size regardless of content changes
                    .fixedSize(horizontal: false, vertical: true)
                }
                
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
                                applyTheme(theme)
                            }) {
                                Text(theme)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(currentThemeForPreview == theme ? Color.accentColor : Color.secondary.opacity(0.2))
                                    )
                                    .foregroundStyle(currentThemeForPreview == theme ? .white : .primary)
                            }
                        }
                    }
                    .padding()
                }
                
                // Reset button
                Button("Reset to Default") {
                    let defaultTheme = colorScheme == .dark ? "monokai" : "xcode"
                    previewTheme = defaultTheme
                    selectedTheme = nil
                    CodeEditorView.ThemePreferences.clearTheme(forLanguage: language)
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

